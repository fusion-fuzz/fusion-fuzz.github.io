# Assertion failure in Objects/codeobject.c advance_with_locations

**Issue:** [https://github.com/python/cpython/issues/140935](https://github.com/python/cpython/issues/140935) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-03T07:44:06Z`

**Labels:** `type-crash`

## Description

# Crash report

### What happened?

```python
import dis
import io
import types
import contextlib
import unittest
class DisTests(unittest.TestCase):
        def f(x):
            return x + 1
        code = f.__code__
        try:
            new_code = code.replace(co_linetable=b'\xa0\xa1')
        except (AttributeError, TypeError, ValueError):
            self.skipTest("code.replace(co_linetable=...) not supported on this Python build")
        fn = types.FunctionType(new_code, f.__globals__, name=f.__name__,
                                argdefs=f.__defaults__, closure=f.__closure__)
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            dis.dis(fn)
```

```
python: ../Objects/codeobject.c:1225: advance_with_locations: Assertion `(second_byte & 128) == 0' failed.
Aborted (core dumped)
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
