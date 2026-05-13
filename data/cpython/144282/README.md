# "Fatal Python error: _PyEval_EvalFrameDefault: Executing a cache" when prepending CACHE opcodes via code.replace

**Issue:** [https://github.com/python/cpython/issues/144282](https://github.com/python/cpython/issues/144282) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-27T17:10:19Z`

**Labels:** `interpreter-core`, `type-crash`

## Description

# Bug report

### Bug description:

```python
from types import FunctionType
import opcode

CACHE = 0 

def external_getitem(self, i):
    # This uses super(), which triggers __class__ cell lookups
    return f'Foreign getitem: {super().__getitem__(i)}'

def create_closure(__class__):
    return (lambda: __class__).__closure__

class List(list):
    pass

orig_code = external_getitem.__code__

# We prepend a CACHE byte (0) and a dummy value (1)
# This shifts the entire bytecode sequence.
new_bytecode = bytes([CACHE, 1]) + orig_code.co_code

# We add '__class__' to freevars to support the super() call
tricky_code = orig_code.replace(
    co_freevars=orig_code.co_freevars + ('__class__',),
    co_code=new_bytecode
)

closure = create_closure(List)
broken_func = FunctionType(tricky_code, globals(), "__getitem__", None, closure)

# The interpreter will try to execute the first byte (CACHE) as an instruction.
obj = List([1, 2, 3])
print(broken_func(obj, 0))
```

```
Fatal Python error: _PyEval_EvalFrameDefault: Executing a cache.
Python runtime state: initialized

Current thread 0x00007bd769626040 [python] (most recent call first):
  File "/home/fuzz/WorkSpace/FusionFuzzLoop/output/bugs/cpython/_PyEval_EvalFrameDefault__Executing_a_cache._e4f9eefb/./mm.py", line 6 in external_getitem
  File "/home/fuzz/WorkSpace/FusionFuzzLoop/output/bugs/cpython/_PyEval_EvalFrameDefault__Executing_a_cache._e4f9eefb/./mm.py", line 33 in <module>
Aborted
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
