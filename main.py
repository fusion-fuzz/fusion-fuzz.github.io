#!/usr/bin/env python3
"""
fusion-fuzz.github.io / main.py
===============================
Renders index.html, one list of every bug in time order, from data/.

    data/bugs.json                      bugs reported upstream
    data/<project>/<number>/            reproducer.<ext>, command.txt, output.txt
    data/unreported.json                distinct crashes not yet reported
    data/unreported/<project>/<id>/     reproducer.<ext>, command.txt, output.txt

Usage:
    python3 main.py                     # data/ -> index.html
"""

import argparse
import collections
import json
import os
from html import escape

REPO = "https://github.com/fusion-fuzz/fusion-fuzz"
STATUS = {"fixed": "Fixed", "confirmed": "Confirmed", "open": "Open", "unreported": "Unreported"}


def load(data_dir):
    bugs, generated = [], ""
    with open(os.path.join(data_dir, "bugs.json"), encoding="utf-8") as fh:
        meta = json.load(fh)
    generated = meta.get("generated", "")
    for b in meta["bugs"]:
        bugs.append(dict(id=b["id"], project=b["project"], title=b["title"], status=b["status"], date=b["reported"],
                         language=b["language"], files=b["files"], url=b["url"], ref=f'{b["tracker"]} {b["label"]}',
                         folder=f'{data_dir}/{b["project"].lower()}/{b["number"]}'))
    path = os.path.join(data_dir, "unreported.json")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            for b in json.load(fh)["bugs"]:
                bugs.append(dict(id=b["id"], project=b["project"], title=b["title"], status="unreported", date=b["found"],
                                 language=b["language"], files=b["files"], url="", ref="",
                                 folder=f'{data_dir}/unreported/{b["slug"]}/{b["id"].split("-")[-1]}'))
    bugs.sort(key=lambda b: (b["date"], b["id"]), reverse=True)
    return generated, bugs


def render_bug(b):
    st = b["status"]
    links = " · ".join(f'<a href="{escape(b["folder"])}/{escape(n)}">{escape(n)}</a>' for n in b["files"].values())
    head = (f'<a href="{escape(b["url"])}" rel="noopener">{escape(b["ref"])}</a><span>Reported {escape(b["date"])}</span>'
            if b["url"] else f'<span>Not reported yet</span><span>Found {escape(b["date"])}</span>')
    search = f'{b["project"]} {b["ref"]} {b["id"]} {b["title"]}'.lower()
    return f"""<details class="bug" id="{escape(b['id'])}" data-p="{escape(b['project'])}" data-s="{st}" data-q="{escape(search)}" data-dir="{escape(b['folder'])}" data-files="{escape(json.dumps(b['files']))}" data-lang="{escape(b['language'])}">
<summary><span class="st st-{st}">{STATUS[st]}</span><span class="pj">{escape(b['project'])}</span><span class="tt">{escape(b['title'])}</span><span class="dt">{escape(b['date'])}</span></summary>
<div class="det"><p class="meta">{head}<span>Files: {links}</span></p><div class="slot"></div></div>
</details>"""


CSS = """
:root {
  --bg: #ffffff; --fg: #1f2328; --muted: #656d76; --line: #d8dee4; --soft: #f6f8fa; --hover: #f3f5f7;
  --link: #0969da; --fixed: #1a7f37; --conf: #9a6700; --open: #6e7781; --unrep: #8c959f;
  --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, "Liberation Mono", monospace;
}
@media (prefers-color-scheme: dark) {
  :root { --bg: #0d1117; --fg: #e6edf3; --muted: #8d96a0; --line: #30363d; --soft: #161b22; --hover: #161b22;
          --link: #4493f8; --fixed: #3fb950; --conf: #d29922; --open: #8d96a0; --unrep: #6e7681; }
}
* { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; }
body { margin: 0; background: var(--bg); color: var(--fg);
       font: 15px/1.5 system-ui, -apple-system, "Segoe UI", Helvetica, Arial, sans-serif; }
a { color: var(--link); text-decoration: none; }
a:hover { text-decoration: underline; }
.wrap { max-width: 1080px; margin: 0 auto; padding: 40px 16px 64px; }
h1 { font-size: 26px; margin: 0 0 4px; letter-spacing: -.01em; }
h1 a { color: inherit; }
h2 { font-size: 13px; margin: 36px 0 10px; text-transform: uppercase; letter-spacing: .06em; color: var(--muted); }
.lead { color: var(--muted); margin: 0; max-width: 46em; }
.repo { margin: 6px 0 0; font-size: 13px; }
.note { margin: 24px 0 0; padding: 12px 16px; border: 1px solid var(--line); border-left: 3px solid var(--link);
        border-radius: 6px; background: var(--soft); font-size: 14px; max-width: 52em; }
.stats { display: grid; grid-template-columns: repeat(4, 1fr); margin: 24px 0 0;
         border: 1px solid var(--line); border-radius: 8px; overflow: hidden; }
.stats div { padding: 14px 18px; border-left: 1px solid var(--line); }
.stats div:first-child { border-left: 0; }
.stats b { display: block; font-size: 24px; font-weight: 600; font-variant-numeric: tabular-nums; }
.stats span { color: var(--muted); font-size: 13px; }
table { width: 100%; border-collapse: collapse; font-variant-numeric: tabular-nums; font-size: 14px; }
th, td { text-align: right; padding: 6px 10px; border-bottom: 1px solid var(--line); }
th:first-child, td:first-child { text-align: left; }
th { font-weight: 600; font-size: 13px; color: var(--muted); }
tr.sel td { background: var(--soft); }
.tools { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-bottom: 12px; }
.tools input, .tools select { font: inherit; font-size: 14px; color: var(--fg); background: var(--bg);
                              border: 1px solid var(--line); border-radius: 6px; padding: 6px 10px; }
.tools input { flex: 1 1 240px; min-width: 0; }
.tools .count { color: var(--muted); font-size: 13px; margin-left: auto; }
.list { border: 1px solid var(--line); border-radius: 8px; overflow: hidden; }
.bug { border-top: 1px solid var(--line); }
.bug.first { border-top: 0; }
.bug summary { list-style: none; cursor: pointer; display: grid; align-items: baseline; gap: 12px;
               grid-template-columns: 96px 84px 1fr auto; padding: 9px 14px; }
.bug summary::-webkit-details-marker { display: none; }
.bug summary:hover { background: var(--hover); }
.bug[open] summary { background: var(--soft); border-bottom: 1px solid var(--line); }
.st { font-size: 12px; font-weight: 600; white-space: nowrap; }
.st::before { content: ""; display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 6px;
              background: currentColor; vertical-align: 1px; }
.st-fixed { color: var(--fixed); } .st-confirmed { color: var(--conf); } .st-open { color: var(--open); }
.st-unreported { color: var(--unrep); font-weight: 500; }
.st-unreported::before { background: transparent; box-shadow: inset 0 0 0 1.5px currentColor; }
.pj { color: var(--muted); font-size: 13px; }
.tt { overflow-wrap: anywhere; }
.dt { color: var(--muted); font-size: 13px; font-variant-numeric: tabular-nums; white-space: nowrap; }
.det { padding: 12px 14px 16px; }
.meta { display: flex; flex-wrap: wrap; gap: 6px 18px; margin: 0 0 4px; font-size: 13px; color: var(--muted); }
.meta a:first-child { font-weight: 600; }
.blk { margin-top: 12px; }
.blk-h { font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: .05em; color: var(--muted); margin-bottom: 4px; }
.blk-h span { font-weight: 400; text-transform: none; letter-spacing: 0; margin-left: 8px; }
pre { margin: 0; background: var(--soft); border: 1px solid var(--line); border-radius: 6px; padding: 10px 12px;
      overflow: auto; max-height: 28em; font: 12.5px/1.45 var(--mono); tab-size: 4; }
.out pre { max-height: 20em; }
.empty { padding: 24px; text-align: center; color: var(--muted); display: none; }
.more { display: block; margin: 12px auto 0; font: inherit; font-size: 14px; padding: 6px 16px; color: var(--fg);
        background: var(--bg); border: 1px solid var(--line); border-radius: 6px; cursor: pointer; }
footer { margin-top: 32px; color: var(--muted); font-size: 13px; }
@media (max-width: 640px) {
  .wrap { padding-top: 24px; }
  .stats { grid-template-columns: repeat(2, 1fr); }
  .stats div:nth-child(3) { border-left: 0; }
  .stats div:nth-child(n+3) { border-top: 1px solid var(--line); }
  .bug summary { grid-template-columns: auto 1fr auto; gap: 2px 10px; }
  .bug .tt { grid-column: 1 / -1; order: 3; }
  th:nth-child(n+4), td:nth-child(n+4) { display: none; }
}
"""

JS = """
(function () {
  var q = document.getElementById('q'), fp = document.getElementById('fp'), fs = document.getElementById('fs');
  var bugs = Array.prototype.slice.call(document.querySelectorAll('.bug'));
  var rows = Array.prototype.slice.call(document.querySelectorAll('#ptable tbody tr'));
  var PAGE = 200, limit = PAGE, more = document.getElementById('more');
  function apply() {
    var t = q.value.trim().toLowerCase().replace(/^#/, ''), p = fp.value, s = fs.value, k = 0, shown = 0;
    bugs.forEach(function (b) {
      var ok = (!p || b.dataset.p === p) && (!s || (s === 'reported' ? b.dataset.s !== 'unreported' : b.dataset.s === s)) &&
               (!t || b.dataset.q.indexOf(t) >= 0);
      if (ok) k++;
      var vis = ok && shown < limit;
      b.style.display = vis ? '' : 'none';
      b.classList.toggle('first', vis && shown === 0);
      if (vis) shown++;
    });
    rows.forEach(function (r) { r.classList.toggle('sel', r.dataset.p === p); });
    document.getElementById('count').textContent = k.toLocaleString() + (k === 1 ? ' bug' : ' bugs');
    document.getElementById('empty').style.display = k ? 'none' : 'block';
    more.style.display = k > shown ? '' : 'none';
  }
  function reset() { limit = PAGE; apply(); }
  q.addEventListener('input', reset); fp.addEventListener('change', reset); fs.addEventListener('change', reset);
  more.addEventListener('click', function () { limit += PAGE; apply(); });
  rows.forEach(function (r) {
    r.querySelector('a').addEventListener('click', function (e) {
      e.preventDefault(); fp.value = fp.value === r.dataset.p ? '' : r.dataset.p; reset();
      document.getElementById('bugs').scrollIntoView({behavior: 'smooth'});
    });
  });
  Array.prototype.forEach.call(document.querySelectorAll('[data-show]'), function (a) {
    a.addEventListener('click', function (e) {
      e.preventDefault(); fs.value = a.dataset.show; reset();
      document.getElementById('bugs').scrollIntoView({behavior: 'smooth'});
    });
  });
  function esc(s) { return s.replace(/[&<>]/g, function (c) { return {'&': '&amp;', '<': '&lt;', '>': '&gt;'}[c]; }); }
  var TITLES = {reproducer: 'Reproducer', command: 'Command', output: 'Output'}, CAP = 120000;
  function load(d) {
    if (d.dataset.loaded) return;
    d.dataset.loaded = '1';
    var files = JSON.parse(d.dataset.files), slot = d.querySelector('.slot');
    ['reproducer', 'command', 'output'].forEach(function (kind) {
      if (!files[kind]) return;
      var div = document.createElement('div'); div.className = 'blk' + (kind === 'output' ? ' out' : '');
      div.innerHTML = '<div class="blk-h">' + TITLES[kind] + (kind === 'reproducer' ? '<span>' + esc(d.dataset.lang) + '</span>' : '') +
                      '</div><pre><code>Loading…</code></pre>';
      slot.appendChild(div);
      fetch(d.dataset.dir + '/' + files[kind]).then(function (r) {
        if (!r.ok) throw new Error(r.status); return r.text();
      }).then(function (t) {
        if (t.length > CAP) t = t.slice(0, CAP) + '\\n[... truncated, see the raw file ...]';
        div.querySelector('code').textContent = t.replace(/\\n$/, '') || '(empty file)';
      }).catch(function () { div.querySelector('code').textContent = 'Could not load ' + files[kind] + '.'; });
    });
  }
  bugs.forEach(function (b) { b.addEventListener('toggle', function () { if (b.open) load(b); }); });
  apply();
  var h = location.hash.slice(1), el = h && document.getElementById(h);
  if (el && el.classList.contains('bug')) { el.style.display = ''; el.open = true; load(el); el.scrollIntoView(); }
})();
"""


def render(generated, bugs):
    n = len(bugs)
    st = collections.Counter(b["status"] for b in bugs)
    reported = n - st["unreported"]
    per = collections.defaultdict(collections.Counter)
    for b in bugs:
        per[b["project"]][b["status"]] += 1
    projects = sorted(per, key=lambda p: (-sum(per[p].values()), p))
    rows = "\n".join(
        f'<tr data-p="{escape(p)}"><td><a href="#bugs">{escape(p)}</a></td><td>{sum(per[p].values())}</td>'
        f'<td>{sum(per[p].values()) - per[p]["unreported"]}</td><td>{per[p]["fixed"]}</td><td>{per[p]["confirmed"]}</td>'
        f'<td>{per[p]["unreported"]}</td></tr>' for p in projects)
    opts = "\n".join(f'<option value="{escape(p)}">{escape(p)} ({sum(per[p].values())})</option>' for p in projects)
    sopts = (f'<option value="reported">Reported ({reported})</option>'
             + "".join(f'<option value="{k}">{STATUS[k]} ({st[k]})</option>' for k in STATUS))
    items = "\n".join(render_bug(b) for b in bugs)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Fusion-Fuzz Bugs</title>
<meta name="description" content="{n:,} bugs found by Fusion-Fuzz in compilers and language runtimes.">
<style>{CSS}</style>
</head>
<body>
<div class="wrap">
<header>
<h1><a href="{REPO}">Fusion-Fuzz</a> Bugs</h1>
<p class="lead">Bugs found by <a href="{REPO}">Fusion-Fuzz</a> in compilers and language runtimes, newest first. Each entry has its reproducer and output; reported bugs link to the upstream report.</p>
<p class="repo"><a href="{REPO}">github.com/fusion-fuzz/fusion-fuzz</a></p>
</header>

<aside class="note"><b>Note.</b> Many bugs found by Fusion-Fuzz have not been reported yet (<a href="#bugs" data-show="unreported">marked Unreported</a>). These are mixed with false alarms and duplicate bugs. We appreciate any effort to validate them and report them to the corresponding vendors. If you do, the credit for the report is yours; please add a note to the report co-crediting <a href="{REPO}">Fusion-Fuzz</a>.</aside>

<section class="stats">
<div><b>{n:,}</b><span>Bugs</span></div>
<div><b>{reported}</b><span>Reported</span></div>
<div><b>{st['fixed']}</b><span>Fixed</span></div>
<div><b>{st['confirmed']}</b><span>Confirmed</span></div>
</section>

<h2>By project</h2>
<table id="ptable">
<thead><tr><th>Project</th><th>Bugs</th><th>Reported</th><th>Fixed</th><th>Confirmed</th><th>Unreported</th></tr></thead>
<tbody>
{rows}
</tbody>
</table>

<h2 id="bugs">All bugs</h2>
<div class="tools">
<input id="q" type="search" placeholder="Search title, issue number or ID" aria-label="Search">
<select id="fp" aria-label="Project"><option value="">All projects</option>
{opts}
</select>
<select id="fs" aria-label="Status"><option value="">All statuses</option>
{sopts}
</select>
<span class="count" id="count">{n:,} bugs</span>
</div>
<div class="list" id="list">
{items}
<div class="empty" id="empty">Nothing matches the filter.</div>
</div>
<button class="more" id="more" type="button">Show more</button>

<footer>
<p><b>Fixed</b>: closed upstream as completed or resolved as fixed. <b>Confirmed</b>: acknowledged by a maintainer (label, assignee, linked pull request, or developer comment). <b>Open</b>: reported, no response yet. <b>Unreported</b>: not reported yet; deduplicated by crash signature (assertion, ICE location, sanitizer report or panic site) and not checked by hand, so some may already be known upstream.</p>
<p>Updated {escape(generated)}. Machine-readable lists: <a href="data/bugs.json">data/bugs.json</a>, <a href="data/unreported.json">data/unreported.json</a>.</p>
</footer>
</div>
<script>{JS}</script>
</body>
</html>
"""


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--data", default="data")
    ap.add_argument("--out", default="index.html")
    a = ap.parse_args()
    generated, bugs = load(a.data)
    with open(a.out, "w", encoding="utf-8") as fh:
        fh.write(render(generated, bugs))
    print(f"{a.out}: {len(bugs):,} bugs, {os.path.getsize(a.out):,} bytes")


if __name__ == "__main__":
    main()
