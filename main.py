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


def _issue_url(project, issue_id):
    base = ISSUE_URL_BASE.get(project.lower())
    if base and re.fullmatch(r"\d+", issue_id):
        return base + issue_id
    return None


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

_FENCE = re.compile(r"```([A-Za-z0-9_+-]*)[ \t]*\n(.*?)```", re.DOTALL)


def readme_blocks(text):
    """(language, code, output) from a GitHub-issue-style README.

    The first tagged fence is the reproducer; the first untagged (or
    text/console/log-tagged) fence after it is the captured output."""
    blocks = _FENCE.findall(text or "")
    if not blocks:
        return "text", "", ""
    lang, code, out = "text", "", ""
    for tag, body in blocks:
        tag = tag.lower()
        if not code:
            if tag:
                lang, code = tag, body.strip()
            continue
        if not out and tag in ("", "text", "txt", "console", "shell", "log"):
            out = body.strip()
    if not code:                      # only untagged fences present
        code = blocks[0][1].strip()
    return lang, code, out


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
            m = re.search(r"^#\s+(.+)", text, re.MULTILINE)
            if m:
                sig = m.group(1).strip()
                # Strip markdown link syntax: [text](url) → text
                sig = re.sub(r"^\[(.+)\]\([^)]*\)$", r"\1", sig)
                result["signature"] = sig
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
    readme = _read(os.path.join(bug_dir, "README.md"))

    # Fused program = original test.* ; minimized reproducer = min.*
    fused_file, fused_raw = _find_file(bug_dir, ["test.", "reproduce."])
    min_file,   min_raw   = _find_file(bug_dir, ["min."])
    fused_ext = os.path.splitext(fused_file)[1].lower() if fused_file else ""
    min_ext   = os.path.splitext(min_file)[1].lower()   if min_file   else ""
    fused_code = _extract_file_section(fused_raw, fused_ext) if fused_file else ""
    min_code   = _extract_file_section(min_raw, min_ext)     if min_file   else ""

    # README-only bugs: the reported snippet is the minimized reproducer
    rd_lang, rd_code, rd_out = readme_blocks(readme)
    if not fused_code and not min_code and rd_code:
        min_file, min_code, min_ext = "README.md", rd_code, ""

    # Parents
    pa_file, pa_raw = _find_file(bug_dir, ["parent_a."])
    pb_file, pb_raw = _find_file(bug_dir, ["parent_b."])
    pa_ext = os.path.splitext(pa_file)[1].lower() if pa_file else ""
    pb_ext = os.path.splitext(pb_file)[1].lower() if pb_file else ""
    pa_code = _extract_file_section(pa_raw, pa_ext) if pa_raw else ""
    pb_code = _extract_file_section(pb_raw, pb_ext) if pb_raw else ""

    # Output: test.out, else the README log
    raw_out = _read(os.path.join(bug_dir, "test.out")).rstrip("\n") or rd_out
    output  = smart_truncate(raw_out) if raw_out else ""

    # Display file (what a reader should run): minimized if present
    repr_file = min_file or fused_file or "test"
    repr_code = min_code or fused_code
    repr_ext  = min_ext if min_code else fused_ext

    return {
        "project":      project,
        "issue_id":     issue_id,
        "issue_url":    _issue_url(project, issue_id),
        "signature":    meta["signature"] or f"Bug #{issue_id}",
        "return_code":  meta["return_code"],
        "date":         meta["date"] or "",
        "command":      meta["command"],
        "language":     EXT_LANG.get(repr_ext, rd_lang if repr_file == "README.md" else "text"),
        "repr_file":    repr_file,
        "repr_code":    repr_code,
        "fused_file":   fused_file or "",
        "fused_code":   fused_code,
        "min_file":     min_file or "",
        "min_code":     min_code,
        "orig_file":    fused_file or "",
        "orig_code":    fused_code if min_code else "",
        "orig_language": EXT_LANG.get(fused_ext, "text"),
        "pa_code":      pa_code,
        "pb_code":      pb_code,
        "pa_file":      pa_file,
        "pb_file":      pb_file,
        "output":       output,
        "is_minimized": bool(min_code),
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
# Per-bug HTML block (plain tags only)
# ---------------------------------------------------------------------------

def _rc_text(rc):
    if rc is None:
        return "exit ?"
    try:
        rc = int(rc)
    except (ValueError, TypeError):
        return _he(str(rc))
    if rc == 124:
        return "timeout"
    return f"exit {rc}"


def _section(title, fname, code, missing="not available"):
    if not code:
        return f'<p>{_he(title)}: {missing}</p>'
    label = f"{title} ({fname})" if fname else title
    return f'<p>{_he(label)}</p>\n<pre><code>{_he(code)}</code></pre>'


def _render_bug(bug):
    proj      = _he(bug["project"])
    issue_id  = _he(bug["issue_id"])
    issue_url = bug["issue_url"]
    sig       = _he(bug["signature"])
    date      = _he(bug["date"])
    rc        = _rc_text(bug["return_code"])
    id_html   = f'<a href="{_he(issue_url)}">#{issue_id}</a>' if issue_url else f'#{issue_id}'

    parts = [f'<details id="{proj}-{issue_id}">',
             f'<summary><b>{id_html}</b> [{proj}, {rc}, {date}] {sig}</summary>',
             _section("Fused program", bug["fused_file"], bug["fused_code"]),
             _section("Minimized reproducer", bug["min_file"], bug["min_code"]),
             _section("Output", "", bug["output"], missing="none captured"),
             _section("Parent A", bug["pa_file"], bug["pa_code"])]
    if bug["pb_code"]:
        parts.append(_section("Parent B", bug["pb_file"], bug["pb_code"]))
    parts.append('</details>')
    return "\n".join(parts)

# ---------------------------------------------------------------------------
# Full HTML page
# ---------------------------------------------------------------------------

def generate_html(bugs, out_path):
    n = len(bugs)
    projects = sorted({b["project"] for b in bugs})
    counts = {p: sum(1 for b in bugs if b["project"] == p) for p in projects}

    index = "\n".join(
        f'<li><a href="#{_he(p)}">{_he(p)}</a> ({counts[p]})</li>' for p in projects)

    sections = []
    for p in projects:
        rows = "\n".join(_render_bug(b) for b in bugs if b["project"] == p)
        sections.append(f'<h2 id="{_he(p)}">{_he(p)} ({counts[p]})</h2>\n{rows}')
    body = "\n".join(sections)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>FusionFuzzLoop Issues</title>
<style>
body {{ max-width: 60em; margin: 1em auto; padding: 0 1em; }}
pre  {{ overflow: auto; max-height: 30em; }}
</style>
</head>
<body>
<h1>FusionFuzzLoop Issues</h1>
<p>{n} issues. Each entry lists the reproduce command, the minimized test case, the captured output, and the parent seed(s).</p>
<ul>
{index}
</ul>
{body}
</body>
</html>
"""
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
