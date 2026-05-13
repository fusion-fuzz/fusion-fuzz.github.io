# global-buffer-overflow PyUnicode_GET_LENGTH cpython/unicodeobject.h

**Issue:** [https://github.com/python/cpython/issues/140471](https://github.com/python/cpython/issues/140471) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-22T17:32:46Z`

**Labels:** `interpreter-core`, `topic-unicode`, `type-crash`

## Description

# Crash report

### What happened?

```python
import ast
import unittest
class ASTConstructorTests(unittest.TestCase):
    def test_incomplete_field_types(self):
        class MoreFieldsThanTypes(ast.AST):
            _fields = (None, 'b')
            _field_types = {'a': int | None}
        with self.assertWarnsRegex(DeprecationWarning, "Field 'b' is missing from MoreFieldsThanTypes\\._field_types"):
            obj = MoreFieldsThanTypes()
if __name__ == "__main__":
    unittest.main()
```

```
=================================================================
==2065858==ERROR: AddressSanitizer: global-buffer-overflow on address 0x55976cbd9450 at pc 0x55976c40a3bf bp 0x7fffcdd98590 sp 0x7fffcdd98580
READ of size 8 at 0x55976cbd9450 thread T0
    #0 0x55976c40a3be in PyUnicode_GET_LENGTH ../Include/cpython/unicodeobject.h:297
    #1 0x55976c40a3be in unicode_fromformat_write_str ../Objects/unicodeobject.c:2611
    #2 0x55976c40f1dd in unicode_fromformat_arg ../Objects/unicodeobject.c:2991
    #3 0x55976c40f1dd in unicode_from_format ../Objects/unicodeobject.c:3165
    #4 0x55976c411f6a in PyUnicode_FromFormatV ../Objects/unicodeobject.c:3199
    #5 0x55976c44bdc2 in _PyErr_WarnFormatV ../Python/_warnings.c:1379
    #6 0x55976c44bdc2 in PyErr_WarnFormat ../Python/_warnings.c:1396
    #7 0x55976c47530b in ast_type_init ../Python/Python-ast.c:5329
    #8 0x55976c3309d7 in type_call ../Objects/typeobject.c:2461
    #9 0x55976c18c4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #10 0x55976c04ba18 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #11 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #12 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #13 0x55976c197d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #14 0x55976c197d90 in method_vectorcall ../Objects/classobject.c:95
    #15 0x55976c192ffe in _PyVectorcall_Call ../Objects/call.c:273
    #16 0x55976c192ffe in _PyObject_Call ../Objects/call.c:348
    #17 0x55976c192ffe in PyObject_Call ../Objects/call.c:373
    #18 0x55976c032eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #19 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #20 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #21 0x55976c191623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #22 0x55976c191cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #23 0x55976c352444 in call_method ../Objects/typeobject.c:3077
    #24 0x55976c352444 in slot_tp_call ../Objects/typeobject.c:10606
    #25 0x55976c18c4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #26 0x55976c0307ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #27 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #28 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #29 0x55976c197d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #30 0x55976c197d90 in method_vectorcall ../Objects/classobject.c:95
    #31 0x55976c192ffe in _PyVectorcall_Call ../Objects/call.c:273
    #32 0x55976c192ffe in _PyObject_Call ../Objects/call.c:348
    #33 0x55976c192ffe in PyObject_Call ../Objects/call.c:373
    #34 0x55976c032eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #35 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #36 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #37 0x55976c191623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #38 0x55976c191cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #39 0x55976c352444 in call_method ../Objects/typeobject.c:3077
    #40 0x55976c352444 in slot_tp_call ../Objects/typeobject.c:10606
    #41 0x55976c18c4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #42 0x55976c02fad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #43 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #44 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #45 0x55976c197d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #46 0x55976c197d90 in method_vectorcall ../Objects/classobject.c:95
    #47 0x55976c192ffe in _PyVectorcall_Call ../Objects/call.c:273
    #48 0x55976c192ffe in _PyObject_Call ../Objects/call.c:348
    #49 0x55976c192ffe in PyObject_Call ../Objects/call.c:373
    #50 0x55976c032eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #51 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #52 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #53 0x55976c191623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #54 0x55976c191cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #55 0x55976c352444 in call_method ../Objects/typeobject.c:3077
    #56 0x55976c352444 in slot_tp_call ../Objects/typeobject.c:10606
    #57 0x55976c18c4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #58 0x55976c02fad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #59 0x55976c512b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #60 0x55976c512b55 in _PyEval_Vector ../Python/ceval.c:2001
    #61 0x55976c191623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #62 0x55976c191cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #63 0x55976c33ec50 in call_method ../Objects/typeobject.c:3077
    #64 0x55976c33ec50 in slot_tp_init ../Objects/typeobject.c:10835
    #65 0x55976c3309d7 in type_call ../Objects/typeobject.c:2461
    #66 0x55976c18c4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #67 0x55976c04ba18 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #68 0x55976c512386 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #69 0x55976c512386 in _PyEval_Vector ../Python/ceval.c:2001
    #70 0x55976c512386 in PyEval_EvalCode ../Python/ceval.c:884
    #71 0x55976c6d0f0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #72 0x55976c6d0f0e in run_mod ../Python/pythonrun.c:1459
    #73 0x55976c6d5bb7 in pyrun_file ../Python/pythonrun.c:1293
    #74 0x55976c6d5bb7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #75 0x55976c6d66dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #76 0x55976c749afc in pymain_run_file_obj ../Modules/main.c:410
    #77 0x55976c749afc in pymain_run_file ../Modules/main.c:429
    #78 0x55976c749afc in pymain_run_python ../Modules/main.c:691
    #79 0x55976c74b3de in Py_RunMain ../Modules/main.c:772
    #80 0x55976c74b3de in pymain_main ../Modules/main.c:802
    #81 0x55976c74b3de in Py_BytesMain ../Modules/main.c:826
    #82 0x71588d93b1c9 in __libc_start_call_main ../sysdeps/nptl/libc_start_call_main.h:58
    #83 0x71588d93b28a in __libc_start_main_impl ../csu/libc-start.c:360
    #84 0x55976c065fa4 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x21afa4) (BuildId: f28384d3eff6aa8d5f0c5730194edf28c0f6b3bd)

0x55976cbd9450 is located 48 bytes before global variable 'none_as_number' defined in '../Objects/object.c:2227:24' (0x55976cbd9480) of size 288
0x55976cbd9450 is located 0 bytes after global variable '_Py_NoneStruct' defined in '../Objects/object.c:2310:10' (0x55976cbd9440) of size 16
SUMMARY: AddressSanitizer: global-buffer-overflow ../Include/cpython/unicodeobject.h:297 in PyUnicode_GET_LENGTH
Shadow bytes around the buggy address:
  0x55976cbd9180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x55976cbd9200: 00 00 00 00 00 00 00 00 f9 f9 f9 f9 00 00 f9 f9
  0x55976cbd9280: f9 f9 f9 f9 00 00 00 00 00 00 00 00 00 00 00 00
  0x55976cbd9300: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x55976cbd9380: 00 00 00 00 00 00 00 00 f9 f9 f9 f9 00 00 00 00
=>0x55976cbd9400: 00 00 00 00 f9 f9 f9 f9 00 00[f9]f9 f9 f9 f9 f9
  0x55976cbd9480: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x55976cbd9500: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x55976cbd9580: 00 00 00 00 f9 f9 f9 f9 00 00 00 00 00 00 00 00
  0x55976cbd9600: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x55976cbd9680: 00 00 00 00 00 00 00 00 00 00 00 00 f9 f9 f9 f9
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
==2065858==ABORTING
```


### CPython versions tested on:

3.15

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140506
* gh-140509
* gh-140510
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
