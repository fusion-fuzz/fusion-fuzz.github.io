# assertion failure at Objects/call.c:618: `PyObject *callmethod(PyThreadState *, PyObject *, const char *, struct __va_list_tag *): Assertion 'callable != NULL' failed.`

**Issue:** [https://github.com/python/cpython/issues/142737](https://github.com/python/cpython/issues/142737) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-15T05:12:38Z`

**Labels:** `interpreter-core`, `type-crash`

## Description

# Crash report

### What happened?

```python
import builtins
import sys

def test_import(name, *args, **kwargs):
    sys.modules[name] = object()
    return sys.modules[name]

builtins.__import__ = test_import

raise RuntimeError("Test")
```

```
python: ../Objects/call.c:618: PyObject *callmethod(PyThreadState *, PyObject *, const char *, struct __va_list_tag *): Assertion `callable != NULL' failed.
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-142747
* gh-142773
* gh-142774
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
