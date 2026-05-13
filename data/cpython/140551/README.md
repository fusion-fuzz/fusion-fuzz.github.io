# Crash in `dict` if `hash` `__eq__` function has side effects

**Issue:** [https://github.com/python/cpython/issues/140551](https://github.com/python/cpython/issues/140551) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-24T14:54:05Z`

**Labels:** `interpreter-core`, `type-crash`, `3.13`, `3.14`, `3.15`

## Description

# Crash report

### What happened?

```python
import unittest
class Test(unittest.TestCase):
    def test(self):
        class X(object):
            def __hash__(self):
                return -1
            def __eq__(self, other):
                    d.clear()
        d = {}
        d[X()] = 3
        d[X()] = 4
        d[0.0] = 6
        self.assertIn(9, d)
if __name__ == "__main__":
    unittest.main()
```

```
=================================================================
==2499578==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x5030000157d8 at pc 0x5a0a74cfb3e4 bp 0x7ffcf57ec450 sp 0x7ffcf57ec440
READ of size 8 at 0x5030000157d8 thread T0
    #0 0x5a0a74cfb3e3 in unicode_get_hash ../Objects/dictobject.c:404
    #1 0x5a0a74cfb3e3 in _PyDict_Next ../Objects/dictobject.c:3022
    #2 0x5a0a74cff6c3 in _PyDict_Next ../Objects/dictobject.c:2994
    #3 0x5a0a74cff6c3 in dict_repr_lock_held ../Objects/dictobject.c:3397
    #4 0x5a0a74cff6c3 in dict_repr ../Objects/dictobject.c:3456
    #5 0x5a0a74d55a8e in PyObject_Repr ../Objects/object.c:779
    #6 0x5a0a74ad9300 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2455
    #7 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #8 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #9 0x5a0a74c3dd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #10 0x5a0a74c3dd90 in method_vectorcall ../Objects/classobject.c:95
    #11 0x5a0a74c38ffe in _PyVectorcall_Call ../Objects/call.c:273
    #12 0x5a0a74c38ffe in _PyObject_Call ../Objects/call.c:348
    #13 0x5a0a74c38ffe in PyObject_Call ../Objects/call.c:373
    #14 0x5a0a74ad8eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #15 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #16 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #17 0x5a0a74c37623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #18 0x5a0a74c37cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #19 0x5a0a74df8444 in call_method ../Objects/typeobject.c:3077
    #20 0x5a0a74df8444 in slot_tp_call ../Objects/typeobject.c:10606
    #21 0x5a0a74c324cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #22 0x5a0a74ad67ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #23 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #24 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #25 0x5a0a74c3dd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #26 0x5a0a74c3dd90 in method_vectorcall ../Objects/classobject.c:95
    #27 0x5a0a74c38ffe in _PyVectorcall_Call ../Objects/call.c:273
    #28 0x5a0a74c38ffe in _PyObject_Call ../Objects/call.c:348
    #29 0x5a0a74c38ffe in PyObject_Call ../Objects/call.c:373
    #30 0x5a0a74ad8eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #31 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #32 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #33 0x5a0a74c37623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #34 0x5a0a74c37cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #35 0x5a0a74df8444 in call_method ../Objects/typeobject.c:3077
    #36 0x5a0a74df8444 in slot_tp_call ../Objects/typeobject.c:10606
    #37 0x5a0a74c324cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #38 0x5a0a74ad5ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #39 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #40 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #41 0x5a0a74c3dd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #42 0x5a0a74c3dd90 in method_vectorcall ../Objects/classobject.c:95
    #43 0x5a0a74c38ffe in _PyVectorcall_Call ../Objects/call.c:273
    #44 0x5a0a74c38ffe in _PyObject_Call ../Objects/call.c:348
    #45 0x5a0a74c38ffe in PyObject_Call ../Objects/call.c:373
    #46 0x5a0a74ad8eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #47 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #48 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #49 0x5a0a74c37623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #50 0x5a0a74c37cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #51 0x5a0a74df8444 in call_method ../Objects/typeobject.c:3077
    #52 0x5a0a74df8444 in slot_tp_call ../Objects/typeobject.c:10606
    #53 0x5a0a74c324cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #54 0x5a0a74ad5ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #55 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #56 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #57 0x5a0a74c37623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #58 0x5a0a74c37cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #59 0x5a0a74de4c50 in call_method ../Objects/typeobject.c:3077
    #60 0x5a0a74de4c50 in slot_tp_init ../Objects/typeobject.c:10835
    #61 0x5a0a74dd69d7 in type_call ../Objects/typeobject.c:2461
    #62 0x5a0a74c324cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #63 0x5a0a74af1a18 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #64 0x5a0a74fb8386 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #65 0x5a0a74fb8386 in _PyEval_Vector ../Python/ceval.c:2001
    #66 0x5a0a74fb8386 in PyEval_EvalCode ../Python/ceval.c:884
    #67 0x5a0a75176f0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #68 0x5a0a75176f0e in run_mod ../Python/pythonrun.c:1459
    #69 0x5a0a7517bbb7 in pyrun_file ../Python/pythonrun.c:1293
    #70 0x5a0a7517bbb7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #71 0x5a0a7517c6dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #72 0x5a0a751efafc in pymain_run_file_obj ../Modules/main.c:410
    #73 0x5a0a751efafc in pymain_run_file ../Modules/main.c:429
    #74 0x5a0a751efafc in pymain_run_python ../Modules/main.c:691
    #75 0x5a0a751f13de in Py_RunMain ../Modules/main.c:772
    #76 0x5a0a751f13de in pymain_main ../Modules/main.c:802
    #77 0x5a0a751f13de in Py_BytesMain ../Modules/main.c:826
    #78 0x7fb1143591c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #79 0x7fb11435928a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #80 0x5a0a74b0bfa4 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x21afa4) (BuildId: f28384d3eff6aa8d5f0c5730194edf28c0f6b3bd)

0x5030000157d8 is located 0 bytes after 24-byte region [0x5030000157c0,0x5030000157d8)
allocated by thread T0 here:
    #0 0x7fb1147279c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5a0a74c9d849 in PyFloat_FromDouble ../Objects/floatobject.c:128
    #2 0x5a0a7522adc1 in fill_time ../Modules/posixmodule.c:2681
    #3 0x5a0a7522b4de in _pystat_fromstructstat ../Modules/posixmodule.c:2796
    #4 0x5a0a7522d2fc in posix_do_stat ../Modules/posixmodule.c:2918
    #5 0x5a0a75237a0c in os_stat_impl ../Modules/posixmodule.c:3285
    #6 0x5a0a75237a0c in os_stat ../Modules/clinic/posixmodule.c.h:105
    #7 0x5a0a74afae79 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #8 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #9 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #10 0x5a0a74c33062 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x5a0a74c33062 in object_vacall ../Objects/call.c:819
    #12 0x5a0a74c366b1 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #13 0x5a0a750814d3 in import_find_and_load ../Python/import.c:3701
    #14 0x5a0a750814d3 in PyImport_ImportModuleLevelObject ../Python/import.c:3783
    #15 0x5a0a74f9ab4c in builtin___import___impl ../Python/bltinmodule.c:285
    #16 0x5a0a74f9ab4c in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #17 0x5a0a74c38ffe in _PyVectorcall_Call ../Objects/call.c:273
    #18 0x5a0a74c38ffe in _PyObject_Call ../Objects/call.c:348
    #19 0x5a0a74c38ffe in PyObject_Call ../Objects/call.c:373
    #20 0x5a0a74ad8eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #21 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #22 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #23 0x5a0a74c33062 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #24 0x5a0a74c33062 in object_vacall ../Objects/call.c:819
    #25 0x5a0a74c366b1 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #26 0x5a0a75081afb in PyImport_ImportModuleLevelObject ../Python/import.c:3853
    #27 0x5a0a74fb3795 in _PyEval_ImportName ../Python/ceval.c:3017
    #28 0x5a0a74aeaa5e in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:6219
    #29 0x5a0a74fb8386 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #30 0x5a0a74fb8386 in _PyEval_Vector ../Python/ceval.c:2001
    #31 0x5a0a74fb8386 in PyEval_EvalCode ../Python/ceval.c:884
    #32 0x5a0a74fa2758 in builtin_exec_impl ../Python/bltinmodule.c:1180
    #33 0x5a0a74fa2758 in builtin_exec ../Python/clinic/bltinmodule.c.h:571
    #34 0x5a0a74c38ffe in _PyVectorcall_Call ../Objects/call.c:273
    #35 0x5a0a74c38ffe in _PyObject_Call ../Objects/call.c:348
    #36 0x5a0a74c38ffe in PyObject_Call ../Objects/call.c:373
    #37 0x5a0a74ad8eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #38 0x5a0a74fb8b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #39 0x5a0a74fb8b55 in _PyEval_Vector ../Python/ceval.c:2001
    #40 0x5a0a74c33062 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #41 0x5a0a74c33062 in object_vacall ../Objects/call.c:819
    #42 0x5a0a74c366b1 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #43 0x5a0a750814d3 in import_find_and_load ../Python/import.c:3701
    #44 0x5a0a750814d3 in PyImport_ImportModuleLevelObject ../Python/import.c:3783
    #45 0x5a0a74f9ab4c in builtin___import___impl ../Python/bltinmodule.c:285
    #46 0x5a0a74f9ab4c in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #47 0x5a0a74c33928 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #48 0x5a0a74c33928 in _PyObject_CallFunctionVa ../Objects/call.c:552

SUMMARY: AddressSanitizer: heap-buffer-overflow ../Objects/dictobject.c:404 in unicode_get_hash
Shadow bytes around the buggy address:
  0x503000015500: fd fd fa fa fd fd fd fd fa fa fd fd fd fd fa fa
  0x503000015580: fd fd fd fd fa fa fd fd fd fd fa fa fd fd fd fa
  0x503000015600: fa fa fd fd fd fd fa fa fd fd fd fd fa fa fd fd
  0x503000015680: fd fd fa fa fd fd fd fd fa fa fd fd fd fd fa fa
  0x503000015700: fd fd fd fd fa fa fd fd fd fd fa fa fd fd fd fd
=>0x503000015780: fa fa fd fd fd fd fa fa 00 00 00[fa]fa fa fd fd
  0x503000015800: fd fd fa fa fd fd fd fa fa fa fd fd fd fd fa fa
  0x503000015880: fd fd fd fa fa fa fd fd fd fd fa fa fd fd fd fd
  0x503000015900: fa fa fd fd fd fd fa fa fd fd fd fd fa fa fd fd
  0x503000015980: fd fd fa fa fd fd fd fd fa fa fd fd fd fd fa fa
  0x503000015a00: fd fd fd fd fa fa fd fd fd fd fa fa fd fd fd fd
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
==2499578==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140558
* gh-140743
* gh-140744
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
