# SEGV functools _Py_dict_lookup

**Issue:** [https://github.com/python/cpython/issues/140590](https://github.com/python/cpython/issues/140590) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-25T15:22:21Z`

**Labels:** `extension-modules`, `type-crash`, `3.15`

## Description

# Crash report

### What happened?

```python
import functools
import unittest
def capture(*args, **kw):
    return (args, kw)
def extract_sig(part):
    return (part.func, part.args, part.keywords, part.__dict__)
class MyTuple(tuple):
    def __add__(self, other):
        return list(self) + list(other)
class MyDict(dict):
    pass
class TestPartialSetstateSubclasses(unittest.TestCase):
        f = functools.partial(extract_sig)
        f.__setstate__((capture, MyTuple((1,)), MyDict(a=10), '\u2603'))
        f.__setstate__((capture, BadTuple((1,)), {}, None))
if __name__ == "__main__":
    import unittest; unittest.main(verbosity=0)
```

```
AddressSanitizer:DEADLYSIGNAL
=================================================================
==197163==ERROR: AddressSanitizer: SEGV on unknown address (pc 0x583829da5bda bp 0x7ffd359603d0 sp 0x7ffd35960320 T0)
==197163==The signal is caused by a READ memory access.
==197163==Hint: this fault was caused by a dereference of a high value address (see register values below).  Disassemble the provided pc to learn which register was used.
    #0 0x583829da5bda in _Py_dict_lookup ../Objects/dictobject.c:1254
    #1 0x583829dae83f in _Py_dict_lookup_threadsafe ../Objects/dictobject.c:1643
    #2 0x583829dae83f in _PyDict_GetMethodStackRef ../Objects/dictobject.c:1691
    #3 0x583829dfc2ff in _PyObject_GetMethodStackRef ../Objects/object.c:1756
    #4 0x583829b831a4 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:7844
    #5 0x58382a057b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #6 0x58382a057b55 in _PyEval_Vector ../Python/ceval.c:2001
    #7 0x58382a0439e8 in builtin___build_class__ ../Python/bltinmodule.c:205
    #8 0x583829cd2ee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #9 0x583829cd2ee7 in PyObject_Vectorcall ../Objects/call.c:327
    #10 0x583829b74ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #11 0x58382a057386 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #12 0x58382a057386 in _PyEval_Vector ../Python/ceval.c:2001
    #13 0x58382a057386 in PyEval_EvalCode ../Python/ceval.c:884
    #14 0x58382a215f0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #15 0x58382a215f0e in run_mod ../Python/pythonrun.c:1459
    #16 0x58382a21abb7 in pyrun_file ../Python/pythonrun.c:1293
    #17 0x58382a21abb7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #18 0x58382a21b6dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #19 0x58382a28eafc in pymain_run_file_obj ../Modules/main.c:410
    #20 0x58382a28eafc in pymain_run_file ../Modules/main.c:429
    #21 0x58382a28eafc in pymain_run_python ../Modules/main.c:691
    #22 0x58382a2903de in Py_RunMain ../Modules/main.c:772
    #23 0x58382a2903de in pymain_main ../Modules/main.c:802
    #24 0x58382a2903de in Py_BytesMain ../Modules/main.c:826
    #25 0x7249b00571c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #26 0x7249b005728a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV ../Objects/dictobject.c:1254 in _Py_dict_lookup
==197163==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140671
* gh-140698
* gh-140699
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
