# Assertion failed: typeinfo->proto in PyCPointerType_from_param_impl when using deprecated POINTER(str) in argtypes

**Issue:** [https://github.com/python/cpython/issues/144100](https://github.com/python/cpython/issues/144100) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-21T07:49:08Z`

**Labels:** `type-bug`, `topic-ctypes`, `extension-modules`

## Description

# Bug report

### Bug description:

```python
import ctypes

# The specific bug is triggered by creating a POINTER type using a string 
# (which issues a DeprecationWarning) and then using it for argument conversion.
BadType = ctypes.POINTER("BugTrigger")

# Load standard library (Linux/POSIX specific, matches the crash environment)
libc = ctypes.CDLL(None)

# Use any standard function (e.g., getpid) to attach argtypes
func = libc.getpid
func.argtypes = (BadType,)

try:
    # Calling the function forces ctypes to run PyCPointerType_from_param_impl
    # on the argument, triggering the "Assertion `typeinfo->proto' failed".
    func(ctypes.byref(ctypes.c_int(0)))
except Exception:
    pass
```

```
python: ../Modules/_ctypes/_ctypes.c:1422: PyObject *PyCPointerType_from_param_impl(PyObject *, PyTypeObject *, PyObject *): Assertion `typeinfo->proto' failed.
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-144108
* gh-144244
* gh-144245
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
