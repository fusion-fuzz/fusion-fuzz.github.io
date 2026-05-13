# SystemError: Objects/codeobject.c bad argument to internal function

**Issue:** [https://github.com/python/cpython/issues/140564](https://github.com/python/cpython/issues/140564) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-24T19:21:32Z`

**Labels:** `type-bug`, `interpreter-core`, `pending`

## Description

# Crash report

### What happened?

```python
c = (lambda x, y, *, z=1, w=1: 1).__code__
swapped = c.replace(co_posonlyargcount=2147483647, co_kwonlyargcount=0)
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
