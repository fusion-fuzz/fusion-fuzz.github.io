# Assertion failure in Python/generated_cases.c.h `PyObject *_PyEval_EvalFrameDefault(PyThreadState *, _PyInterpreterFrame *, int): Assertion 'oparg == co->co_nfreevars' failed`

**Issue:** [https://github.com/python/cpython/issues/141390](https://github.com/python/cpython/issues/141390) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-11-11T08:17:40Z`

**Labels:** `type-crash`

## Description

# Crash report

### What happened?

```python
import opcode
from types import FunctionType

COPY_FREE_VARS = opcode.opmap.get('COPY_FREE_VARS', None)
if COPY_FREE_VARS is None:
    raise SystemExit("skip: opcode COPY_FREE_VARS not available on this Python")

def external_getitem(self, i):
    return f'Foreign getitem: {super().__getitem__(i)}'

def create_closure(__class__):
    return (lambda: __class__).__closure__

def new_code(c):
    prep = bytes([COPY_FREE_VARS, 0])
    return c.replace(
        co_freevars=c.co_freevars + ('__class__',),
        co_code=prep + c.co_code
    )

def add_foreign_method(cls, name, f):
    code = new_code(f.__code__)
    closure = create_closure(cls)
    defaults = f.__defaults__
    setattr(cls, name, FunctionType(code, globals(), name, defaults, closure))

class List(list):
    pass

add_foreign_method(List, '__getitem__', external_getitem)
obj = List([1, 2, 3])
result = obj[0]
```

```
python: ../Python/generated_cases.c.h:5129: PyObject *_PyEval_EvalFrameDefault(PyThreadState *, _PyInterpreterFrame *, int): Assertion `oparg == co->co_nfreevars' failed.
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
