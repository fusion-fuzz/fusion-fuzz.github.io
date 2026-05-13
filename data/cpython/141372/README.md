# memory leak in `cProfile.Profile`

**Issue:** [https://github.com/python/cpython/issues/141372](https://github.com/python/cpython/issues/141372) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2025-11-10T20:08:47Z`

**Labels:** `type-bug`, `extension-modules`, `topic-profiling`

## Description

# Bug report

### Bug description:

```python
import cProfile
import sys

class _MonitoringStub:
    MISSING = object()

sys.monitoring = _MonitoringStub()

prof = cProfile.Profile()
```

```
=================================================================
==1718547==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 40 byte(s) in 1 object(s) allocated from:
    #0 0x6338266bcf93 in malloc (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x338f93) (BuildId: 8c1b704a48f26c5c3e2e3abf679137700b62a68e)
    #1 0x633826a046fe in _PyMem_DebugRawAlloc /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/obmalloc.c:2887:24
    #2 0x633826a046fe in _PyMem_DebugRawMalloc /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/obmalloc.c:2920:12
    #3 0x633826a046fe in _PyMem_DebugMalloc /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/obmalloc.c:3085:12
    #4 0x633826a4048c in _PyObject_MallocWithType /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_object_alloc.h:46:17
    #5 0x633826a4048c in _PyType_AllocNoTrack /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/typeobject.c:2515:19
    #6 0x633826a402ed in PyType_GenericAlloc /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/typeobject.c:2546:21
    #7 0x633826a4cbed in type_call /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/typeobject.c:2459:11
    #8 0x6338268ac2d6 in _PyObject_MakeTpCall /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/call.c:242:18
    #9 0x633826c46948 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:1620:35
    #10 0x633826c14898 in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:121:16
    #11 0x633826c14898 in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2005:12
    #12 0x633826c03b08 in builtin___build_class__ /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/bltinmodule.c:205:12
    #13 0x6338268ab862 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:169:11
    #14 0x633826c46948 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:1620:35
    #15 0x633826c14898 in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:121:16
    #16 0x633826c14898 in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2005:12
    #17 0x633826c13fcb in PyEval_EvalCode /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:888:21
    #18 0x633826de94f3 in run_eval_code_obj /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1365:12
    #19 0x633826de94f3 in run_mod /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1459:19
    #20 0x633826de17bc in pyrun_file /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1293:15
    #21 0x633826de17bc in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:521:13
    #22 0x633826de0bc2 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:81:15
    #23 0x633826e567d3 in pymain_run_file_obj /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:410:15
    #24 0x633826e567d3 in pymain_run_file /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:429:15
    #25 0x633826e54bc6 in pymain_run_python /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:691:21
    #26 0x633826e54bc6 in Py_RunMain /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:772:5
    #27 0x633826e55837 in pymain_main /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:802:12
    #28 0x633826e559a3 in Py_BytesMain /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:826:12
    #29 0x76cd2ee241c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #30 0x76cd2ee2428a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

SUMMARY: AddressSanitizer: 40 byte(s) leaked in 1 allocation(s).
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
