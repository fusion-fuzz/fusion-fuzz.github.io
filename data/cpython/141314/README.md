# Assertion failure in Modules/_io/textio.c `_io_TextIOWrapper_tell_impl: Assertion 'skip_back <= PyBytes_GET_SIZE(next_input)' failed`

**Issue:** [https://github.com/python/cpython/issues/141314](https://github.com/python/cpython/issues/141314) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-09T18:34:47Z`

**Labels:** `extension-modules`, `topic-IO`, `type-crash`

## Description

# Bug report

### Bug description:

```python
import io
import os
from test.support import os_helper

DATA_TEMPLATE = ['line1=1']
DATA_CR = r'\n\r\t'.join(DATA_TEMPLATE) + '\r'

open_func = io.open

READMODE = 'r'
WRITEMODE = 'wb'

data = DATA_CR
if 'b' in WRITEMODE:
    data = data.encode('ascii')

with open_func(os_helper.TESTFN, WRITEMODE) as fp:
    fp.write(data)

with open_func(os_helper.TESTFN, READMODE) as fp:
    _ = fp.readline()
    pos = fp.tell()
```

```
python: ../Modules/_io/textio.c:2848: _io_TextIOWrapper_tell_impl: Assertion `skip_back <= PyBytes_GET_SIZE(next_input)' failed.
Aborted (core dumped)
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-141331
* gh-141452
* gh-141453
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
