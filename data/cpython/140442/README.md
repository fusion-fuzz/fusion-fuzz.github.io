# LeakSan: 80-byte leak at shutdown after atexit.register of bound list.append(-0.0)

**Issue:** [https://github.com/python/cpython/issues/140442](https://github.com/python/cpython/issues/140442) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-22T03:34:29Z`

**Labels:** `type-bug`, `interpreter-core`

## Description

# Bug report

### Bug description:

```python
import atexit
import unittest
class GeneralTest(unittest.TestCase):
    def setUp(self):
        atexit._clear()
    def tearDown(self):
            self.assertEqual(type(cm.unraisable.exc_value), exc_type)
    def test_bound_methods(self):
        l = []
        atexit.register(l.append, -0.0)
if __name__ == '__main__':
    unittest.main()
```

```
=================================================================
==1285431==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 56 byte(s) in 1 object(s) allocated from:
    #0 0x7bf3de9cf9c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5a8fc7f6127e in _PyObject_MallocWithType ../Include/internal/pycore_object_alloc.h:46
    #2 0x5a8fc7f6127e in gc_alloc ../Python/gc.c:2343
    #3 0x5a8fc7f6127e in _PyObject_GC_NewVar ../Python/gc.c:2385
    #4 0x5a8fc7cd0cab in tuple_alloc ../Objects/tupleobject.c:57
    #5 0x5a8fc7cd476d in PyTuple_FromArray ../Objects/tupleobject.c:393
    #6 0x5a8fc7cd476d in PyTuple_FromArray ../Objects/tupleobject.c:387
    #7 0x5a8fc7b44437 in _PyObject_MakeTpCall ../Objects/call.c:216
    #8 0x5a8fc7b46316 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:167
    #9 0x5a8fc7b46316 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:154
    #10 0x5a8fc7b46316 in PyObject_CallOneArg ../Objects/call.c:395
    #11 0x5a8fc7f3062a in _PyErr_CreateException ../Python/errors.c:43
    #12 0x5a8fc7f30d4a in _PyErr_SetObject ../Python/errors.c:180
    #13 0x5a8fc7f3044d in _PyErr_SetObject ../Python/errors.c:157
    #14 0x5a8fc7f3044d in _PyErr_FormatV ../Python/errors.c:1210
    #15 0x5a8fc7f3044d in PyErr_Format ../Python/errors.c:1243
    #16 0x5a8fc7c6b0b8 in _PyObject_GenericGetAttrWithDict ../Objects/object.c:1908
    #17 0x5a8fc7c69907 in PyObject_GetAttr ../Objects/object.c:1313
    #18 0x5a8fc7c6b5bc in PyObject_GetOptionalAttr ../Objects/object.c:1377
    #19 0x5a8fc7eab5ab in builtin_getattr ../Python/bltinmodule.c:1238
    #20 0x5a8fc7b45ee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #21 0x5a8fc7b45ee7 in PyObject_Vectorcall ../Objects/call.c:327
    #22 0x5a8fc79e7ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #23 0x5a8fc7ecab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #24 0x5a8fc7ecab55 in _PyEval_Vector ../Python/ceval.c:2001
    #25 0x5a8fc7b4fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #26 0x5a8fc7b4fd90 in method_vectorcall ../Objects/classobject.c:95
    #27 0x5a8fc7b4affe in _PyVectorcall_Call ../Objects/call.c:273
    #28 0x5a8fc7b4affe in _PyObject_Call ../Objects/call.c:348
    #29 0x5a8fc7b4affe in PyObject_Call ../Objects/call.c:373
    #30 0x5a8fc79eaeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #31 0x5a8fc7ecab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #32 0x5a8fc7ecab55 in _PyEval_Vector ../Python/ceval.c:2001
    #33 0x5a8fc7b49623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #34 0x5a8fc7b49cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #35 0x5a8fc7d0a444 in call_method ../Objects/typeobject.c:3077
    #36 0x5a8fc7d0a444 in slot_tp_call ../Objects/typeobject.c:10606
    #37 0x5a8fc7b444cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #38 0x5a8fc79e87ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #39 0x5a8fc7ecab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #40 0x5a8fc7ecab55 in _PyEval_Vector ../Python/ceval.c:2001
    #41 0x5a8fc7b4fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #42 0x5a8fc7b4fd90 in method_vectorcall ../Objects/classobject.c:95
    #43 0x5a8fc7b4affe in _PyVectorcall_Call ../Objects/call.c:273
    #44 0x5a8fc7b4affe in _PyObject_Call ../Objects/call.c:348
    #45 0x5a8fc7b4affe in PyObject_Call ../Objects/call.c:373
    #46 0x5a8fc79eaeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #47 0x5a8fc7ecab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #48 0x5a8fc7ecab55 in _PyEval_Vector ../Python/ceval.c:2001

Indirect leak of 24 byte(s) in 1 object(s) allocated from:
    #0 0x7bf3de9cf9c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5a8fc7baf849 in PyFloat_FromDouble ../Objects/floatobject.c:128
    #2 0x5a8fc813cdc1 in fill_time ../Modules/posixmodule.c:2681
    #3 0x5a8fc813d4de in _pystat_fromstructstat ../Modules/posixmodule.c:2796
    #4 0x5a8fc813f2fc in posix_do_stat ../Modules/posixmodule.c:2918
    #5 0x5a8fc8149a0c in os_stat_impl ../Modules/posixmodule.c:3285
    #6 0x5a8fc8149a0c in os_stat ../Modules/clinic/posixmodule.c.h:105
    #7 0x5a8fc7a0ce79 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #8 0x5a8fc7ecab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #9 0x5a8fc7ecab55 in _PyEval_Vector ../Python/ceval.c:2001
    #10 0x5a8fc7b45062 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x5a8fc7b45062 in object_vacall ../Objects/call.c:819
    #12 0x5a8fc7b486b1 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #13 0x5a8fc7f934d3 in import_find_and_load ../Python/import.c:3701
    #14 0x5a8fc7f934d3 in PyImport_ImportModuleLevelObject ../Python/import.c:3783
    #15 0x5a8fc7eacb4c in builtin___import___impl ../Python/bltinmodule.c:285
    #16 0x5a8fc7eacb4c in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #17 0x5a8fc7b45928 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #18 0x5a8fc7b45928 in _PyObject_CallFunctionVa ../Objects/call.c:552
    #19 0x5a8fc7b469b9 in PyObject_CallFunction ../Objects/call.c:574
    #20 0x5a8fc7f94a0b in PyImport_Import ../Python/import.c:3975
    #21 0x5a8fc7f951bf in PyImport_ImportModule ../Python/import.c:3423
    #22 0x5a8fc7ed5ce2 in _PyCodec_InitRegistry ../Python/codecs.c:1686
    #23 0x5a8fc7debe24 in _PyUnicode_InitEncodings ../Objects/unicodeobject.c:15455
    #24 0x5a8fc80738ab in init_interp_main ../Python/pylifecycle.c:1228
    #25 0x5a8fc807752c in pyinit_main ../Python/pylifecycle.c:1420
    #26 0x5a8fc807752c in Py_InitializeFromConfig ../Python/pylifecycle.c:1451
    #27 0x5a8fc80fefd9 in pymain_init ../Modules/main.c:68
    #28 0x5a8fc8103362 in pymain_main ../Modules/main.c:793
    #29 0x5a8fc8103362 in Py_BytesMain ../Modules/main.c:826
    #30 0x7bf3de6011c9 in __libc_start_call_main ../sysdeps/nptl/libc_start_call_main.h:58
    #31 0x7bf3de60128a in __libc_start_main_impl ../csu/libc-start.c:360
    #32 0x5a8fc7a1dfa4 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x21afa4) (BuildId: f28384d3eff6aa8d5f0c5730194edf28c0f6b3bd)

SUMMARY: AddressSanitizer: 80 byte(s) leaked in 2 allocation(s).
```

### CPython versions tested on:

3.15

### Operating systems tested on:

Linux

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
