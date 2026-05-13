# Assertion failure in Objects/call.c `_PyObject_VectorcallDictTstate: Assertion `!_PyErr_Occurred(tstate)' failed.`

**Issue:** [https://github.com/python/cpython/issues/141307](https://github.com/python/cpython/issues/141307) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-09T17:56:33Z`

**Labels:** `type-bug`, `interpreter-core`, `pending`

## Description

# Bug report

### Bug description:

```python
import importlib.machinery as machinery
import importlib.util
import os
import sys

is_apple_mobile = False

if hasattr(machinery, "ExtensionFileLoader"):
    LoaderClass = machinery.ExtensionFileLoader

dummy_name = "fake_extension_module_for_test"

dummy_path = __file__

loader = LoaderClass(dummy_name, dummy_path)
spec = importlib.util.spec_from_loader(dummy_name, loader)
module = importlib.util.module_from_spec(spec)
```

```
python: ../Objects/call.c:120: _PyObject_VectorcallDictTstate: Assertion `!_PyErr_Occurred(tstate)' failed.
Aborted (core dumped)
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
