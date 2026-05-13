# Memory leak in curses module when calling initscr() after setupterm()

**Issue:** [https://github.com/python/cpython/issues/144067](https://github.com/python/cpython/issues/144067) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2026-01-20T11:36:42Z`

**Labels:** `type-bug`, `extension-modules`

## Description

# Bug report

### Bug description:

```python
import curses
import sys
import os

# Ensure TERM is set so setupterm doesn't fail
if not os.environ.get('TERM'):
    os.environ['TERM'] = 'xterm'

# 1. First allocation (from TestCurses.setUpClass)
# This allocates the first 'struct term' and assigns it to the global cur_term.
try:
    curses.setupterm(fd=sys.stdout.fileno())
except curses.error:
    # If setupterm fails (e.g. no terminal info), we can't reproduce the leak.
    sys.exit(0)

# 2. Second allocation (from TestCurses.setUp -> curses.initscr)
# initscr() internally calls newterm(), which allocates a NEW 'struct term'.
# This overwrites the global cur_term pointer, leaking the memory from step 1.
stdscr = curses.initscr()

# Cleanup (standard curses exit, though the leak has already happened)
curses.endwin()
```

```
=================================================================
==149149==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 760 byte(s) in 1 object(s) allocated from:
    #0 0x5f83747a0189 in calloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x386189) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160ed819 in _nc_setupterm (/lib/x86_64-linux-gnu/libtinfo.so.6+0x1b819) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 4106 byte(s) in 3 object(s) allocated from:
    #0 0x5f83747a03ac in realloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x3863ac) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160e26cc in _nc_doalloc (/lib/x86_64-linux-gnu/libtinfo.so.6+0x106cc) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 3904 byte(s) in 1 object(s) allocated from:
    #0 0x5f837479ffb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160e1fff  (/lib/x86_64-linux-gnu/libtinfo.so.6+0xffff) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 1614 byte(s) in 1 object(s) allocated from:
    #0 0x5f837479ffb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160ecacd in _nc_read_termtype (/lib/x86_64-linux-gnu/libtinfo.so.6+0x1aacd) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)
    #2 0x726574780610019c  (<unknown module>)

Indirect leak of 940 byte(s) in 1 object(s) allocated from:
    #0 0x5f837479ffb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160ed287 in _nc_read_termtype (/lib/x86_64-linux-gnu/libtinfo.so.6+0x1b287) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)
    #2 0x726574780610019c  (<unknown module>)

Indirect leak of 608 byte(s) in 1 object(s) allocated from:
    #0 0x5f837479ffb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160e2119  (/lib/x86_64-linux-gnu/libtinfo.so.6+0x10119) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 608 byte(s) in 1 object(s) allocated from:
    #0 0x5f83747a0189 in calloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x386189) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160ed37e in _nc_read_termtype (/lib/x86_64-linux-gnu/libtinfo.so.6+0x1b37e) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 78 byte(s) in 1 object(s) allocated from:
    #0 0x5f837479ffb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160e204b  (/lib/x86_64-linux-gnu/libtinfo.so.6+0x1004b) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 46 byte(s) in 1 object(s) allocated from:
    #0 0x5f837479ffb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160e1fde  (/lib/x86_64-linux-gnu/libtinfo.so.6+0xffde) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

Indirect leak of 6 byte(s) in 1 object(s) allocated from:
    #0 0x5f83747864fa in strdup (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x36c4fa) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x7691160ed8ae in _nc_setupterm (/lib/x86_64-linux-gnu/libtinfo.so.6+0x1b8ae) (BuildId: e22ba7829a55a0dec2201a0b6dac7ba236118561)

SUMMARY: AddressSanitizer: 12670 byte(s) leaked in 12 allocation(s).
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-144076
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
