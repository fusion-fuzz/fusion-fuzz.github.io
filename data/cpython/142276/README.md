# JIT Assertion failure `_POP_TOP_INT.c:119: _Py_CODEUNIT *_JIT_ENTRY(_PyInterpreterFrame *, _PyStackRef *, PyThreadState *): Assertion 'PyLong_CheckExact(PyStackRef_AsPyObjectBorrow(value))' failed`

**Issue:** [https://github.com/python/cpython/issues/142276](https://github.com/python/cpython/issues/142276) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-05T03:08:10Z`

**Labels:** `interpreter-core`, `type-crash`, `topic-JIT`

## Description

# Crash report

### What happened?

```python
from concurrent.futures import ThreadPoolExecutor
from unittest import TestCase
NTHREADS = 6
BOTTOM = 0
TOP = 0xffffffffffffffff
class A:
    attr = 10**1000
class TestType(TestCase):
        def read(id0):
                for _ in range(BOTTOM, TOP):
                    A.attr
        def write(id0):
                    x = A.attr
                    x += 1
                    A.attr = x
        with ThreadPoolExecutor(NTHREADS) as pool:
            pool.submit(read, (1,))
            pool.submit(write, (1,))
```

```
python: _POP_TOP_INT.c:119: _Py_CODEUNIT *_JIT_ENTRY(_PyInterpreterFrame *, _PyStackRef *, PyThreadState *): Assertion `PyLong_CheckExact(PyStackRef_AsPyObjectBorrow(value))' failed.
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-142303
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
