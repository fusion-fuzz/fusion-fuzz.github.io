# Memory leak in _dbm.open (libdb) when file creation fails (ENOENT)

**Issue:** [https://github.com/python/cpython/issues/144069](https://github.com/python/cpython/issues/144069) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-20T11:51:14Z`

**Labels:** `type-bug`, `extension-modules`, `pending`

## Description

# Bug report

### Bug description:

```python
import _dbm
import os

# Ensure we are pointing to a directory that definitely does not exist
# to trigger the specific 'ENOENT' failure path in the underlying library.
filename = "non_existent_directory_xyz/test.db"

# The leak occurs here:
# 1. _dbm.open calls into libdb (Berkeley DB via ndbm interface).
# 2. libdb allocates internal structures.
# 3. libdb attempts to open/create the file and fails because the directory is missing.
# 4. The error propagates up, but the internal structures are not fully freed.
try:
    _dbm.open(filename, 'c', 0o666)
except OSError:
    pass
```

```
=================================================================
==206240==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 1456 byte(s) in 1 object(s) allocated from:
    #0 0x57cae5ceefb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x6d3a96c8e454 in __os_malloc (/lib/x86_64-linux-gnu/libdb-5.3.so+0x146454) (BuildId: 6dc2ccece58bc114d1ce20f521a527cc5862e054)

Indirect leak of 3814 byte(s) in 10 object(s) allocated from:
    #0 0x57cae5ceefb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x6d3a96c8e454 in __os_malloc (/lib/x86_64-linux-gnu/libdb-5.3.so+0x146454) (BuildId: 6dc2ccece58bc114d1ce20f521a527cc5862e054)

SUMMARY: AddressSanitizer: 5270 byte(s) leaked in 11 allocation(s).
```

Is it likely an upstream bug from libdb?

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-144075
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
