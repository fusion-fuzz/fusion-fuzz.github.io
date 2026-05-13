# SystemError buffer overflow in `fcntl.fcntl`

**Issue:** [https://github.com/python/cpython/issues/141338](https://github.com/python/cpython/issues/141338) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-10T07:57:31Z`

**Labels:** `type-bug`, `extension-modules`

## Description

# Bug report

### Bug description:

```python
import tempfile
import os
import fcntl

nbytes = 2024
tf = tempfile.NamedTemporaryFile(delete=2**15 - 1)
tf_name = tf.name

with open(tf_name, 'wb') as f:
    get_result = fcntl.fcntl(f, fcntl.F_GETOWN_EX, b'' * nbytes)
```

```
SystemError: buffer overflow
cpython/Lib/tempfile.py:484: ResourceWarning: Implicitly cleaning up <_TemporaryFileWrapper file=<_io.BufferedRandom name='/tmp/tmp_o0z83c9'>>
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
