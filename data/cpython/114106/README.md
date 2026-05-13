# segfault when compiling gc referrers referents with frozenset

**Issue:** [https://github.com/python/cpython/issues/114106](https://github.com/python/cpython/issues/114106) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2024-01-16T10:10:30Z`

**Labels:** `type-crash`

## Description

# Crash report

### What happened?

PoC:
```python
xxx = """
import gc
class Cls:
	var = []
gc_get_referrers_list=gc.get_referrers(Cls.var)
for ref in gc_get_referrers_list:
	del ref['var']
gc_collect_arg0=2
gc.collect(gc_collect_arg0)
gc_get_referents_arg0=frozenset({"a", "b", "c"})
gc_get_referents_list=gc.get_referents(gc_get_referents_arg0)
gc_get_referrers_list=gc.get_referrers(Cls.var)
"""

x = compile(xxx, "test", "exec")
exec(x)
```
It might be related to #113631 but here it throws tuple error:
```
../Include/object.h:1023: _Py_NegativeRefcount: Assertion failed: object has negative ref count
Enable tracemalloc to get the memory block allocation traceback

object address  : 0x10553d4a0
object refcount : 0
object type     : 0x104fd1aa0
object type name: tuple
object repr     : <refcnt 0 at 0x10553d4a0>

Fatal Python error: _PyObject_AssertFailed: _PyObject_AssertFailed
Python runtime state: initialized
```
Running the program directly does not throw error:
```
import gc
class Cls:
	var = []
gc_get_referrers_list=gc.get_referrers(Cls.var)
for ref in gc_get_referrers_list:
	del ref['var']
gc_collect_arg0=2
gc.collect(gc_collect_arg0)
gc_get_referents_arg0=frozenset({"a", "b", "c"})
gc_get_referents_list=gc.get_referents(gc_get_referents_arg0)
gc_get_referrers_list=gc.get_referrers(Cls.var)
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

macOS

### Output from running 'python -VV' on the command line:

Python 3.13.0a2+ (heads/main-dirty:42b90cf0d6, Jan 16 2024, 11:20:02) [Clang 14.0.0 (clang-1400.0.29.202)]

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
