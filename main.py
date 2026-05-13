#!/usr/bin/env python3
"""
fusion-fuzz.github.io / main.py
================================
Scans  data/<project>/<issue_id>/  and regenerates  index.html.

Directory layout expected per bug:
    data/
      php/
        21952/              ← GitHub issue number (folder name = issue ID)
          min.php           ← minimized reproducer  (preferred display)
          min.phpt          ← alternative minimized  (optional)
          parent_a.php(t)   ← parent A
          parent_b.php(t)   ← parent B
          test.php(t)       ← original (pre-minimization) reproducer
          test.out          ← combined stdout + stderr
          test.sh           ← reproduce command
          README.md         ← bug report

Usage:
    python3 main.py                         # reads ./data, writes ./index.html
    python3 main.py --data data --out index.html
"""

import argparse
import os
import re
import sys
from datetime import datetime, timezone
from html import escape as _he

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DEFAULT_DATA = "data"
DEFAULT_OUT  = "index.html"

# Issue tracker base URL per project (issue ID appended)
ISSUE_URL_BASE = {
    "php":     "https://github.com/php/php-src/issues/",
    "cpython": "https://github.com/python/cpython/issues/",
    "go":      "https://github.com/golang/go/issues/",
    "rust":    "https://github.com/rust-lang/rust/issues/",
    "swift":   "https://github.com/swiftlang/swift/issues/",
    "lean":    "https://github.com/leanprover/lean4/issues/",
    "llvm":    "https://github.com/llvm/llvm-project/issues/",
    "v8":      "https://issues.chromium.org/issues/",
    "webkit":  "https://bugs.webkit.org/show_bug.cgi?id=",
}

PROJECT_COLORS = {
    "php":     "#7b5ea7",
    "cpython": "#3572A5",
    "go":      "#00ADD8",
    "rust":    "#dea584",
    "swift":   "#F05138",
    "mlir":    "#9B59B6",
    "clang":   "#A8B9CC",
    "naga":    "#e67e22",
    "lean":    "#2ecc71",
    "v8":      "#f1c40f",
    "sql":     "#1abc9c",
}

EXT_LANG = {
    ".py":   "python",
    ".phpt": "php",
    ".php":  "php",
    ".rs":   "rust",
    ".go":   "go",
    ".c":    "c",
    ".cpp":  "cpp",
    ".js":   "javascript",
    ".lean": "lean",
    ".sql":  "sql",
    ".md":   "markdown",
}

CRASH_ANCHORS = [
    "SUMMARY: AddressSanitizer",
    "SUMMARY: UndefinedBehaviorSanitizer",
    "SUMMARY: MemorySanitizer",
    "SUMMARY: ThreadSanitizer",
    "ERROR: AddressSanitizer",
    "ERROR: MemorySanitizer",
    "runtime error:",
    "Assertion:",
    "Fatal error:",
    "Segmentation fault",
    "(core dumped)",
    "zend_mm_heap corrupted",
]

MAX_OUTPUT_CHARS = 48_000
LINES_BEFORE_ANCHOR = 25
LINES_AFTER_ANCHOR  = 300

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

def smart_truncate(text, max_chars=MAX_OUTPUT_CHARS):
    if len(text) <= max_chars:
        return text
    lines = text.splitlines()
    anchor = next(
        (i for i, l in enumerate(lines) if any(p in l for p in CRASH_ANCHORS)),
        None,
    )
    if anchor is None:
        keep    = lines[-LINES_AFTER_ANCHOR:]
        skipped = len(lines) - len(keep)
        return (f"[... {skipped:,} lines truncated — no crash signature; showing tail ...]\n"
                + "\n".join(keep))
    start = max(0, anchor - LINES_BEFORE_ANCHOR)
    end   = min(len(lines), anchor + LINES_AFTER_ANCHOR)
    parts = []
    if start > 0:
        sb = sum(len(l) + 1 for l in lines[:start])
        parts.append(f"[... {start:,} lines / {sb:,} bytes truncated before crash signature ...]")
    parts.append("\n".join(lines[start:end]))
    if end < len(lines):
        parts.append(f"[... {len(lines)-end:,} more lines truncated ...]")
    return "\n".join(parts)


def _read(path):
    try:
        return open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        return ""


def _project_color(project):
    return PROJECT_COLORS.get(project.lower(), "#95a5a6")


def _issue_url(project, issue_id):
    base = ISSUE_URL_BASE.get(project.lower())
    if base and re.fullmatch(r"\d+", issue_id):
        return base + issue_id
    return None


def _rc_badge(rc):
    if rc is None:
        return '<span class="status-chip chip-unknown">?</span>'
    try:
        rc = int(rc)
    except (ValueError, TypeError):
        return f'<span class="status-chip chip-unknown">{_he(str(rc))}</span>'
    if rc == 0:
        return '<span class="status-chip chip-ok">OK 0</span>'
    if rc == 124:
        return '<span class="status-chip chip-warn">TIMEOUT</span>'
    return f'<span class="status-chip chip-crash">CRASH {rc}</span>'


def _find_file(directory, prefixes, skip_suffixes=(".sh", ".out", ".md")):
    """Return (filename, content) for the first matching file, preferring
    shorter extensions (e.g. .php over .phpt for the same prefix)."""
    candidates = []
    for fname in sorted(os.listdir(directory)):
        if any(fname.endswith(s) for s in skip_suffixes):
            continue
        for pfx in prefixes:
            if fname.startswith(pfx):
                candidates.append(fname)
    if not candidates:
        return None, ""
    # Prefer plain .php over .phpt (shorter / cleaner display)
    candidates.sort(key=lambda f: (len(os.path.splitext(f)[1]), f))
    fname = candidates[0]
    return fname, _read(os.path.join(directory, fname))


def _extract_file_section(content, ext):
    """For .phpt files return just the --FILE-- section; otherwise return as-is."""
    if ext == ".phpt" and "--FILE--" in content:
        m = re.search(r"--FILE--\s*\n(.*?)(?=\n--[A-Z_]+--|$)", content, re.DOTALL)
        if m:
            return m.group(1).strip()
    return content.strip()

# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

def _parse_readme(bug_dir):
    """Extract signature, return_code, date, reproduce_command from README.md."""
    result = {"signature": None, "return_code": None, "date": None, "command": ""}
    text = _read(os.path.join(bug_dir, "README.md")) \
        or _read(os.path.join(bug_dir, "report.md"))
    if text:
        m = re.search(r"\*\*Signature:\*\*\s*`([^`]+)`", text)
        if m:
            result["signature"] = m.group(1)
        m = (re.search(r"\*\*RC:\*\*\s*`([^`]+)`", text) or
             re.search(r"\*\*Return Code:\*\*\s*`([^`]+)`", text))
        if m:
            try:
                result["return_code"] = int(m.group(1))
            except ValueError:
                result["return_code"] = m.group(1)
        # H1 heading as fallback signature (used by GitHub-issue-style READMEs)
        if result["signature"] is None:
            m = re.match(r"^#\s+(.+)", text, re.MULTILINE)
            if m:
                result["signature"] = m.group(1).strip()
        # Explicit date field wins over mtime — stable across re-runs and edits.
        # Accepts: **Date:** `YYYY-MM-DD`  OR  **Created:** `YYYY-MM-DDThh:mm:ssZ`
        m = re.search(r"\*\*(?:Date|Created):\*\*\s*`([^`]+)`", text)
        if m:
            raw = m.group(1).strip()
            # Accept ISO timestamp or plain date
            date_m = re.match(r"(\d{4}-\d{2}-\d{2})", raw)
            if date_m:
                result["date"] = date_m.group(1)
    # Fall back to mtime only when no explicit date is embedded in the file
    if result["date"] is None:
        for name in ("README.md", "report.md"):
            p = os.path.join(bug_dir, name)
            if os.path.exists(p):
                result["date"] = datetime.fromtimestamp(
                    os.path.getmtime(p), tz=timezone.utc
                ).strftime("%Y-%m-%d")
                break
    # Reproduce command from test.sh / reproduce.sh
    sh = (_read(os.path.join(bug_dir, "test.sh")) or
          _read(os.path.join(bug_dir, "reproduce.sh")))
    if sh:
        cmd_lines = [l.rstrip() for l in sh.splitlines()
                     if l.strip() and not l.startswith("#")]
        result["command"] = "\n".join(cmd_lines)
    return result


def parse_bug(project, issue_id, bug_dir):
    """Return a bug dict for one data/<project>/<issue_id>/ directory."""
    meta = _parse_readme(bug_dir)

    # Minimized file (preferred) → fall back to original test.*
    min_file,  min_raw  = _find_file(bug_dir, ["min."])
    test_file, test_raw = _find_file(bug_dir, ["test.", "reproduce."])

    repr_file = min_file or test_file
    repr_raw  = min_raw  if min_file else test_raw
    ext       = os.path.splitext(repr_file)[1].lower() if repr_file else ""
    repr_code = _extract_file_section(repr_raw, ext)

    # Fall back to README.md so every bug has something to display
    if not repr_code:
        readme_raw = _read(os.path.join(bug_dir, "README.md"))
        if readme_raw:
            repr_file = "README.md"
            repr_code = readme_raw.strip()
            ext       = ".md"

    # Original file (separate from minimized when both exist)
    orig_ext  = os.path.splitext(test_file)[1].lower() if test_file else ""
    orig_code = _extract_file_section(test_raw, orig_ext) if test_file and min_file else ""

    # Parents
    pa_file, pa_raw = _find_file(bug_dir, ["parent_a."])
    pb_file, pb_raw = _find_file(bug_dir, ["parent_b."])
    pa_ext = os.path.splitext(pa_file)[1].lower() if pa_file else ""
    pb_ext = os.path.splitext(pb_file)[1].lower() if pb_file else ""
    pa_code = _extract_file_section(pa_raw, pa_ext) if pa_raw else ""
    pb_code = _extract_file_section(pb_raw, pb_ext) if pb_raw else ""

    # Output
    raw_out = _read(os.path.join(bug_dir, "test.out")).rstrip("\n")
    output  = smart_truncate(raw_out) if raw_out else ""

    return {
        "project":      project,
        "issue_id":     issue_id,
        "issue_url":    _issue_url(project, issue_id),
        "signature":    meta["signature"] or f"Bug #{issue_id}",
        "return_code":  meta["return_code"],
        "date":         meta["date"] or "",
        "command":      meta["command"],
        "language":     EXT_LANG.get(ext, "text"),
        "repr_file":    repr_file or "test",
        "repr_code":    repr_code,
        "orig_file":    test_file or "",
        "orig_code":    orig_code,
        "orig_language": EXT_LANG.get(orig_ext, "text"),
        "pa_code":      pa_code,
        "pb_code":      pb_code,
        "pa_file":      pa_file,
        "pb_file":      pb_file,
        "output":       output,
        "is_minimized": bool(min_file),
    }


def scan(data_dir):
    bugs = []
    if not os.path.isdir(data_dir):
        sys.exit(f"Error: data dir not found: {data_dir}")
    for project in sorted(os.listdir(data_dir)):
        pdir = os.path.join(data_dir, project)
        if not os.path.isdir(pdir):
            continue
        for issue_id in sorted(os.listdir(pdir), key=lambda x: int(x) if x.isdigit() else x):
            bdir = os.path.join(pdir, issue_id)
            if not os.path.isdir(bdir):
                continue
            try:
                bug = parse_bug(project, issue_id, bdir)
                bugs.append(bug)
                print(f"  [{project}#{issue_id}] {bug['signature'][:72]}")
            except Exception as e:
                print(f"  ERROR [{project}/{issue_id}]: {e}", file=sys.stderr)
    # Sort: date descending (latest first), then numeric issue ID descending
    bugs.sort(key=lambda b: (
        b["date"] or "0000-00-00",
        int(b["issue_id"]) if b["issue_id"].isdigit() else 0,
    ), reverse=True)
    return bugs

# ---------------------------------------------------------------------------
# Attribution rendering
# ---------------------------------------------------------------------------

def _line_set(txt):
    return {l.strip() for l in (txt or "").splitlines() if l.strip()}


def _attr_legend(pa, pb):
    if not pa and not pb:
        return ""
    items = []
    if pa:
        items.append('<span class="attr-leg-item">'
                     '<span class="attr-pin pin-a">A</span>'
                     '<span class="attr-leg-name">parent_a</span></span>')
    if pb:
        items.append('<span class="attr-leg-item">'
                     '<span class="attr-pin pin-b">B</span>'
                     '<span class="attr-leg-name">parent_b</span></span>')
    if pa and pb:
        items.append('<span class="attr-leg-item">'
                     '<span class="attr-pin pin-both">A·B</span>'
                     '<span class="attr-leg-name">both</span></span>')
    items.append('<span class="attr-leg-item">'
                 '<span class="attr-pin pin-novel">new</span>'
                 '<span class="attr-leg-name">novel / fused</span></span>')
    return '<div class="attr-legend">' + "".join(items) + "</div>"


def _attr_block(code, pa, pb):
    """Render code with per-line A/B/both/novel colouring."""
    set_a, set_b = _line_set(pa), _line_set(pb)
    parts = ['<div class="attr-code">']
    for lineno, line in enumerate((code or "").splitlines() or [""], 1):
        stripped = line.strip()
        lno = f'<span class="attr-lno">{lineno}</span>'
        txt = f'<code class="attr-text">{_he(line)}</code>'
        if not stripped:
            parts.append(f'<div class="attr-line attr-empty">{lno}'
                         f'<span class="attr-pin"></span>'
                         f'<code class="attr-text">&nbsp;</code></div>')
            continue
        in_a, in_b = stripped in set_a, stripped in set_b
        if in_a and in_b:
            cls, pin = "attr-both",  '<span class="attr-pin pin-both">A·B</span>'
        elif in_a:
            cls, pin = "attr-a",     '<span class="attr-pin pin-a">A</span>'
        elif in_b:
            cls, pin = "attr-b",     '<span class="attr-pin pin-b">B</span>'
        else:
            cls, pin = "attr-novel", '<span class="attr-pin pin-novel">new</span>'
        parts.append(f'<div class="attr-line {cls}">{lno}{pin}{txt}</div>')
    parts.append("</div>")
    return "".join(parts)

# ---------------------------------------------------------------------------
# Per-bug HTML card
# ---------------------------------------------------------------------------

def _render_bug(i, bug):
    proj      = bug["project"]
    issue_id  = bug["issue_id"]
    issue_url = bug["issue_url"]
    sig       = _he(bug["signature"])
    color     = _project_color(proj)
    rc_badge  = _rc_badge(bug["return_code"])
    date      = _he(bug["date"])
    lang      = bug["language"]
    repr_code = bug["repr_code"]
    orig_code = bug["orig_code"]
    orig_file = bug["orig_file"]
    pa_code   = bug["pa_code"]
    pb_code   = bug["pb_code"]
    output    = _he(smart_truncate(bug["output"]))
    cmd       = _he(bug["command"])
    is_min    = bug["is_minimized"]
    repr_file = _he(bug["repr_file"] or "test")

    # Issue ID: link if a URL is known, otherwise plain text
    if issue_url:
        id_html = (f'<a class="issue-id issue-link" '
                   f'href="{_he(issue_url)}" target="_blank" '
                   f'rel="noopener" onclick="event.stopPropagation()">'
                   f'#{_he(issue_id)}</a>')
    else:
        id_html = f'<span class="issue-id">#{_he(issue_id)}</span>'

    # ── Reproducer pane (minimized with attribution) ──────────────────────
    if pa_code or pb_code:
        repr_pane = _attr_legend(pa_code, pb_code) + _attr_block(repr_code, pa_code, pb_code)
    else:
        repr_pane = (f'<pre class="code-block lang-{lang}">'
                     f'<code>{_he(repr_code)}</code></pre>')

    tab_label = repr_file
    if is_min:
        tab_label += " (minimized)"

    # ── Original pane (shown only when a separate minimized file exists) ──
    orig_tab_html = ""
    orig_pane_html = ""
    if is_min and orig_code:
        if pa_code or pb_code:
            orig_pane_content = (_attr_legend(pa_code, pb_code)
                                 + _attr_block(orig_code, pa_code, pb_code))
        else:
            olang = bug["orig_language"]
            orig_pane_content = (f'<pre class="code-block lang-{olang}">'
                                 f'<code>{_he(orig_code)}</code></pre>')
        orig_tab_html  = (f'<button class="tab" onclick="switchTab({i},\'orig\',this)">'
                          f'{_he(orig_file)} (original)</button>')
        orig_pane_html = (f'<div class="tab-pane" id="pane-orig-{i}" hidden>'
                          f'{orig_pane_content}</div>')

    # ── Output pane ───────────────────────────────────────────────────────
    output_pane = (f'<pre class="code-block"><code>{output}</code></pre>'
                   if output else '<p class="empty-pane">No output captured.</p>')

    # ── Parents pane ──────────────────────────────────────────────────────
    parent_entries = ""
    for label, code, fname in [("parent_a", pa_code, bug.get("pa_file")),
                                ("parent_b", pb_code, bug.get("pb_file"))]:
        if not code:
            continue
        ext = os.path.splitext(fname)[1].lower() if fname else ""
        plang = EXT_LANG.get(ext, "text")
        parent_entries += (
            f'<div class="parent-entry">'
            f'<div class="parent-meta">'
            f'<span class="parent-lbl">{label}</span>'
            f'<span class="parent-pid">{_he(fname or "")}</span>'
            f'</div>'
            f'<pre class="code-block lang-{plang}"><code>{_he(code)}</code></pre>'
            f'</div>'
        )
    parents_pane = (parent_entries if parent_entries
                    else '<p class="empty-pane">No parent information recorded.</p>')
    parents_count = sum(1 for c in [pa_code, pb_code] if c)
    parents_label = f"Parents ({parents_count})" if parents_count else "Parents"

    # ── Command bar ───────────────────────────────────────────────────────
    cmd_bar = ""
    if cmd:
        cmd_bar = (f'<div class="cmd-bar">'
                   f'<code class="cmd-text">{cmd}</code>'
                   f'<button class="copy-btn" onclick="copyCmd(this)" '
                   f'data-cmd="{cmd}">Copy</button>'
                   f'</div>')

    return f"""
  <div class="issue-row" data-project="{_he(proj)}" data-index="{i}" id="issue-{i}">
    <div class="row-summary" onclick="toggleDetail({i})">
      <div class="row-left">
        <span class="proj-dot" style="background:{color}"></span>
        {id_html}
        <span class="issue-title" title="{sig}">{sig}</span>
      </div>
      <div class="row-right">
        <span class="proj-chip" style="color:{color};border-color:{color}44;background:{color}14">{_he(proj)}</span>
        {rc_badge}
        <span class="issue-date">{date}</span>
        <span class="expand-icon" id="icon-{i}">›</span>
      </div>
    </div>
    <div class="issue-detail" id="detail-{i}" hidden>
      <div class="detail-tabs">
        <button class="tab active" onclick="switchTab({i},'repr',this)">{_he(tab_label)}</button>
        {orig_tab_html}
        <button class="tab" onclick="switchTab({i},'output',this)">Output</button>
        <button class="tab" onclick="switchTab({i},'parents',this)">{_he(parents_label)}</button>
      </div>
      {cmd_bar}
      <div class="tab-pane" id="pane-repr-{i}">{repr_pane}</div>
      {orig_pane_html}
      <div class="tab-pane" id="pane-output-{i}" hidden>{output_pane}</div>
      <div class="tab-pane" id="pane-parents-{i}" hidden>{parents_pane}</div>
    </div>
  </div>"""

# ---------------------------------------------------------------------------
# Full HTML page
# ---------------------------------------------------------------------------

CSS = """\
:root {
  --font: -apple-system, "Google Sans", Roboto, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --mono: "Roboto Mono", "SFMono-Regular", Consolas, "Liberation Mono", monospace;
  --bg:        #f1f3f4;
  --surface:   #ffffff;
  --border:    #dadce0;
  --border-l:  #e8eaed;
  --text-1:    #202124;
  --text-2:    #5f6368;
  --text-3:    #80868b;
  --blue:      #1a73e8;
  --blue-bg:   #e8f0fe;
  --blue-text: #1558b0;
  --red:       #d93025;
  --red-bg:    #fce8e6;
  --amber:     #b06000;
  --amber-bg:  #fef7e0;
  --green:     #137333;
  --green-bg:  #e6f4ea;
  --top-h:     56px;
  --side-w:    210px;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: var(--font); font-size: 14px; background: var(--bg); color: var(--text-1); min-height: 100vh; line-height: 1.5; }

/* ── Top bar ─────────────────────────────────────────────────────────── */
.topbar {
  position: sticky; top: 0; z-index: 100;
  height: var(--top-h);
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  display: flex; align-items: center; gap: 16px; padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0,0,0,.08);
}
.logo { font-size: .95rem; font-weight: 600; color: var(--text-1); white-space: nowrap; display: flex; align-items: center; gap: 6px; }
.logo-icon { font-size: 1.1rem; }
.logo-sep { color: var(--border); font-weight: 300; font-size: 1.2rem; }
.logo-sub { color: var(--text-2); font-weight: 400; }
.topbar-search {
  flex: 1; max-width: 560px;
  display: flex; align-items: center;
  background: var(--bg); border: 1px solid var(--border); border-radius: 24px;
  padding: 0 14px; gap: 8px;
  transition: border-color .2s, box-shadow .2s, background .2s;
}
.topbar-search:focus-within { border-color: var(--blue); box-shadow: 0 0 0 3px var(--blue-bg); background: var(--surface); }
.search-icon { color: var(--text-3); font-size: 15px; flex-shrink: 0; }
.search-input { flex: 1; border: none; background: transparent; outline: none; font-size: 14px; color: var(--text-1); padding: 8px 0; }
.search-input::placeholder { color: var(--text-3); }
.topbar-end { margin-left: auto; display: flex; align-items: center; gap: 12px; }
.total-badge {
  font-size: 12px; color: var(--text-2);
  background: var(--bg); border: 1px solid var(--border);
  border-radius: 12px; padding: 2px 10px; white-space: nowrap;
}
.total-badge strong { color: var(--text-1); }

/* ── Layout ──────────────────────────────────────────────────────────── */
.layout { display: flex; max-width: 1440px; margin: 0 auto; padding: 20px 20px 60px; gap: 20px; align-items: flex-start; }

/* ── Sidebar ─────────────────────────────────────────────────────────── */
.sidebar {
  width: var(--side-w); flex-shrink: 0;
  background: var(--surface); border: 1px solid var(--border); border-radius: 8px;
  overflow: hidden; position: sticky; top: calc(var(--top-h) + 16px);
}
.sidebar-heading {
  padding: 14px 16px 8px;
  font-size: 11px; font-weight: 700; letter-spacing: .8px;
  text-transform: uppercase; color: var(--text-3);
}
.filter-item {
  display: flex; align-items: center; gap: 8px;
  width: 100%; padding: 8px 14px;
  background: transparent; border: none; cursor: pointer;
  font-size: 13px; color: var(--text-2); text-align: left;
  transition: background .12s;
}
.filter-item:hover { background: var(--bg); }
.filter-item.active { color: var(--blue); background: var(--blue-bg); font-weight: 500; }
.fi-dot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }
.fi-name { flex: 1; }
.fi-count {
  font-size: 11px; color: var(--text-3);
  background: var(--bg); border-radius: 10px;
  padding: 1px 7px; min-width: 22px; text-align: center;
}
.filter-item.active .fi-count { background: var(--surface); color: var(--blue-text); }
.sidebar-divider { border: none; border-top: 1px solid var(--border-l); }

/* ── Issue list ──────────────────────────────────────────────────────── */
.issue-list {
  flex: 1; min-width: 0;
  background: var(--surface); border: 1px solid var(--border); border-radius: 8px;
  overflow: hidden;
}
.list-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 9px 16px;
  background: var(--bg); border-bottom: 1px solid var(--border);
  font-size: 12px; color: var(--text-2);
}
.list-header-label { font-weight: 600; color: var(--text-1); }
.no-results { text-align: center; padding: 64px 24px; color: var(--text-3); font-size: 15px; display: none; }

/* ── Issue row ───────────────────────────────────────────────────────── */
.issue-row { border-bottom: 1px solid var(--border-l); }
.issue-row:last-child { border-bottom: none; }
.issue-row.hidden { display: none; }
.row-summary {
  display: flex; align-items: center; padding: 0 16px;
  min-height: 52px; cursor: pointer; gap: 12px;
  transition: background .1s;
}
.row-summary:hover { background: #f8f9fa; }
.issue-row.expanded > .row-summary { background: var(--blue-bg); }
.row-left { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }
.proj-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.issue-id { font-family: var(--mono); font-size: 12px; color: var(--blue); white-space: nowrap; flex-shrink: 0; font-weight: 600; }
.issue-link { text-decoration: none; }
.issue-link:hover { text-decoration: underline; }
.issue-title { font-size: 13.5px; color: var(--text-1); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.row-right { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.proj-chip {
  font-size: 11px; font-weight: 600; padding: 2px 8px;
  border-radius: 12px; border: 1px solid;
  text-transform: uppercase; letter-spacing: .3px; white-space: nowrap;
}
.status-chip { font-size: 11px; font-weight: 600; padding: 2px 9px; border-radius: 12px; white-space: nowrap; }
.chip-ok      { background: var(--green-bg); color: var(--green); }
.chip-crash   { background: var(--red-bg);   color: var(--red);   }
.chip-warn    { background: var(--amber-bg); color: var(--amber); }
.chip-unknown { background: var(--bg);       color: var(--text-3); border: 1px solid var(--border); }
.issue-date { font-size: 12px; color: var(--text-3); white-space: nowrap; }
.expand-icon { font-size: 20px; color: var(--text-3); transition: transform .18s; line-height: 1; width: 20px; text-align: center; flex-shrink: 0; }
.issue-row.expanded .expand-icon { transform: rotate(90deg); color: var(--blue); }

/* ── Detail panel ────────────────────────────────────────────────────── */
.issue-detail { border-top: 1px solid var(--border); }
.detail-tabs {
  display: flex; padding: 0 16px;
  border-bottom: 1px solid var(--border);
  background: #fafafa; gap: 0; overflow-x: auto;
}
.tab {
  padding: 10px 16px; border: none; background: transparent;
  cursor: pointer; font-size: 13px; color: var(--text-2);
  border-bottom: 2px solid transparent; margin-bottom: -1px;
  white-space: nowrap; transition: color .15s; font-family: var(--font);
}
.tab:hover { color: var(--text-1); }
.tab.active { color: var(--blue); border-bottom-color: var(--blue); font-weight: 500; }
.cmd-bar {
  display: flex; align-items: center; gap: 8px;
  padding: 8px 16px; background: #f8f9fa;
  border-bottom: 1px solid var(--border);
}
.cmd-text {
  flex: 1; font-family: var(--mono); font-size: 12px; color: var(--blue-text);
  overflow: auto; white-space: nowrap; line-height: 1.6;
}
.copy-btn {
  background: var(--surface); border: 1px solid var(--border); border-radius: 4px;
  color: var(--text-2); font-size: 12px; padding: 4px 12px;
  cursor: pointer; white-space: nowrap; transition: all .15s; flex-shrink: 0;
  font-family: var(--font);
}
.copy-btn:hover { background: var(--blue-bg); color: var(--blue); border-color: var(--blue); }
.tab-pane { }
.code-block {
  margin: 0; padding: 16px; font-size: 12.5px; overflow: auto;
  max-height: 520px; background: #f8f9fa !important;
  border-radius: 0; line-height: 1.65;
}
.code-block code { font-family: var(--mono); }
.empty-pane { padding: 20px 16px; color: var(--text-3); font-size: 13px; font-style: italic; }
.parent-entry { border-bottom: 1px solid var(--border-l); padding: 12px 16px; }
.parent-entry:last-child { border-bottom: none; }
.parent-meta { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; flex-wrap: wrap; }
.parent-lbl { font-weight: 600; font-size: 12px; color: var(--blue); font-family: var(--mono); }
.parent-pid { font-size: 12px; color: var(--text-3); font-family: var(--mono); }

/* ── Per-line attribution view ───────────────────────────────────────── */
.attr-legend {
  display: flex; align-items: center; flex-wrap: wrap; gap: 0;
  padding: 7px 14px; border-bottom: 1px solid var(--border-l);
  background: #fafafa; font-size: 11.5px; color: var(--text-2);
}
.attr-leg-item {
  display: flex; align-items: center; gap: 5px;
  padding: 2px 14px 2px 0; margin-right: 6px;
  border-right: 1px solid var(--border-l);
}
.attr-leg-item:last-child { border-right: none; }
.attr-leg-name { font-size: 11.5px; color: var(--text-2); white-space: nowrap; }
.attr-pin {
  display: inline-flex; align-items: center; justify-content: center;
  min-width: 28px; padding: 1px 4px;
  border-radius: 3px; font-size: 10px; font-weight: 700;
  font-family: var(--font); line-height: 1.5; white-space: nowrap;
}
.pin-a     { background: #c2d7f5; color: #1558b0; }
.pin-b     { background: #b7e0c4; color: #0d6830; }
.pin-both  { background: #e2c9f5; color: #6a1b9a; }
.pin-novel { background: #fde8a0; color: #7a5900; }
.attr-code {
  font-family: var(--mono); font-size: 12.5px; line-height: 1.65;
  overflow: auto; max-height: 520px; background: var(--surface); margin: 0;
}
.attr-line {
  display: flex; align-items: baseline;
  padding: 0 16px 0 0; min-height: 1.65em;
}
.attr-line:hover { filter: brightness(.97); }
.attr-lno {
  width: 38px; min-width: 38px; text-align: right; padding-right: 10px;
  color: var(--text-3); font-size: 11px; user-select: none; flex-shrink: 0;
}
.attr-line .attr-pin {
  width: 32px; min-width: 32px; margin-right: 10px; flex-shrink: 0;
  vertical-align: baseline;
}
.attr-text { flex: 1; white-space: pre; }
.attr-a     { background: #edf3ff; }
.attr-b     { background: #edfaf2; }
.attr-both  { background: #f5eeff; }
.attr-novel { background: #fffbee; }
.attr-empty { background: var(--surface); }

/* ── Responsive ──────────────────────────────────────────────────────── */
@media (max-width: 800px) {
  .layout { flex-direction: column; padding: 12px; gap: 12px; }
  .sidebar { width: 100%; position: static; display: flex; flex-wrap: wrap; align-items: center; gap: 4px; padding: 8px; }
  .sidebar-heading { display: none; }
  .sidebar-divider { display: none; }
  .filter-item { width: auto; border-radius: 20px; padding: 5px 12px; border: 1px solid var(--border); }
  .filter-item.active { border-color: var(--blue); }
  .topbar { padding: 0 12px; gap: 10px; }
  .issue-date { display: none; }
}
"""

JS = """\
// ── Row expand / collapse ────────────────────────────────────────────────
function toggleDetail(i) {
  const row    = document.getElementById('issue-' + i);
  const detail = document.getElementById('detail-' + i);
  const wasHidden = detail.hidden;
  detail.hidden = !wasHidden;
  row.classList.toggle('expanded', wasHidden);
  if (wasHidden && !detail.dataset.hl) {
    detail.querySelectorAll('pre.code-block code').forEach(el => {
      const m = el.closest('pre').className.match(/lang-(\\w+)/);
      if (m) el.className = 'language-' + m[1];
      hljs.highlightElement(el);
    });
    detail.dataset.hl = '1';
  }
}

// ── Tab switching ────────────────────────────────────────────────────────
function switchTab(i, name, btn) {
  const detail = document.getElementById('detail-' + i);
  detail.querySelectorAll('.tab-pane').forEach(p => { p.hidden = true; });
  detail.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  document.getElementById('pane-' + name + '-' + i).hidden = false;
  btn.classList.add('active');
}

// ── Project filter ───────────────────────────────────────────────────────
let activeProject = 'all';

function setProject(proj, btn) {
  activeProject = proj;
  document.querySelectorAll('.filter-item').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  applyFilters();
}

function applyFilters() {
  const q = document.getElementById('searchInput').value.toLowerCase();
  let visible = 0;
  document.querySelectorAll('.issue-row').forEach(row => {
    const proj = row.dataset.project;
    const show = (activeProject === 'all' || proj === activeProject)
              && (!q || row.innerText.toLowerCase().includes(q));
    row.classList.toggle('hidden', !show);
    if (show) visible++;
  });
  document.getElementById('no-results').style.display = visible === 0 ? 'block' : 'none';
  document.getElementById('visible-count').textContent = visible;
}

// ── Copy command ─────────────────────────────────────────────────────────
function copyCmd(btn) {
  navigator.clipboard.writeText(btn.dataset.cmd).then(() => {
    const orig = btn.textContent;
    btn.textContent = 'Copied!';
    setTimeout(() => { btn.textContent = orig; }, 1500);
  });
}

// ── Init sidebar counts ───────────────────────────────────────────────────
(function() {
  const counts = {};
  document.querySelectorAll('.issue-row').forEach(r => {
    const p = r.dataset.project;
    counts[p] = (counts[p] || 0) + 1;
  });
  Object.entries(counts).forEach(([p, n]) => {
    const el = document.getElementById('count-' + p);
    if (el) el.textContent = n;
  });
})();
"""


def _sidebar_project_buttons(bugs):
    projects = sorted({b["project"] for b in bugs})
    buttons = []
    for proj in projects:
        color = _project_color(proj)
        buttons.append(
            f'<button class="filter-item" data-project="{_he(proj)}" '
            f'onclick="setProject(\'{_he(proj)}\',this)">'
            f'<span class="fi-dot" style="background:{color}"></span>'
            f'<span class="fi-name">{_he(proj)}</span>'
            f'<span class="fi-count" id="count-{_he(proj)}"></span>'
            f'</button>'
        )
    return "\n    ".join(buttons)


def generate_html(bugs, out_path):
    n = len(bugs)
    rows = "\n".join(_render_bug(i, b) for i, b in enumerate(bugs))
    sidebar_btns = _sidebar_project_buttons(bugs)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FusionFuzzLoop — Issues</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
<style>
{CSS}
</style>
</head>
<body>

<header class="topbar">
  <div class="logo">
    <span class="logo-icon">⚡</span>
    FusionFuzzLoop
    <span class="logo-sep">/</span>
    <span class="logo-sub">Issues</span>
  </div>
  <div class="topbar-search">
    <span class="search-icon">&#x1F50D;</span>
    <input class="search-input" type="text" id="searchInput"
           placeholder="Search issues…" oninput="applyFilters()">
  </div>
  <div class="topbar-end">
    <span class="total-badge"><strong id="visible-count">{n}</strong> issues</span>
  </div>
</header>

<div class="layout">
  <aside class="sidebar">
    <div class="sidebar-heading">Project</div>
    <button class="filter-item active" data-project="all" onclick="setProject('all',this)">
      <span class="fi-dot" style="background:var(--blue)"></span>
      <span class="fi-name">All projects</span>
      <span class="fi-count" id="count-all">{n}</span>
    </button>
    <hr class="sidebar-divider">
    {sidebar_btns}
  </aside>

  <main class="issue-list">
    <div class="list-header">
      <span class="list-header-label">Issue</span>
      <span>Project &nbsp;·&nbsp; Status &nbsp;·&nbsp; Date</span>
    </div>
    <div id="no-results" class="no-results">No issues match the current filter.</div>
{rows}
  </main>
</div>

<script>
{JS}
</script>
</body>
</html>"""

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"\nWrote {out_path}  ({n} issues, {os.path.getsize(out_path):,} bytes)")

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Generate index.html from data/<project>/<issue_id>/")
    ap.add_argument("--data", default=DEFAULT_DATA, metavar="DIR",
                    help=f"Data directory (default: {DEFAULT_DATA})")
    ap.add_argument("--out",  default=DEFAULT_OUT,  metavar="FILE",
                    help=f"Output HTML file (default: {DEFAULT_OUT})")
    args = ap.parse_args()

    print(f"Scanning {args.data} …")
    bugs = scan(args.data)
    print(f"Found {len(bugs)} issue(s).")
    generate_html(bugs, args.out)
