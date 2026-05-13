# memory leak in array.array

**Issue:** [https://github.com/python/cpython/issues/140474](https://github.com/python/cpython/issues/140474) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-22T19:21:11Z`

**Labels:** `type-bug`, `extension-modules`

## Description

# Bug report

### Bug description:

```python
import unittest
import array
class UnicodeTest(unittest.TestCase):
    typecode = 'u'
    def test(self):
        invalid_str = ''
        a = array.array(self.typecode, invalid_str)
if __name__ == "__main__":
    unittest.main()
```

```
=================================================================
==2132310==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 4 byte(s) in 1 object(s) allocated from:
    #0 0x7e19c9bb79c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x6233e8b99bb8 in PyUnicode_AsWideCharString ../Objects/unicodeobject.c:3380
    #2 0x7e19c6456922 in array_new ../Modules/arraymodule.c:2822
    #3 0x6233e8aec8e8 in type_call ../Objects/typeobject.c:2449
    #4 0x6233e89484cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #5 0x6233e87ebad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #6 0x6233e8cceb55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #7 0x6233e8cceb55 in _PyEval_Vector ../Python/ceval.c:2001
    #8 0x6233e8953d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #9 0x6233e8953d90 in method_vectorcall ../Objects/classobject.c:95
    #10 0x6233e894effe in _PyVectorcall_Call ../Objects/call.c:273
    #11 0x6233e894effe in _PyObject_Call ../Objects/call.c:348
    #12 0x6233e894effe in PyObject_Call ../Objects/call.c:373
    #13 0x6233e87eeeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #14 0x6233e8cceb55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #15 0x6233e8cceb55 in _PyEval_Vector ../Python/ceval.c:2001
    #16 0x6233e894d623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #17 0x6233e894dcdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #18 0x6233e8b0e444 in call_method ../Objects/typeobject.c:3077
    #19 0x6233e8b0e444 in slot_tp_call ../Objects/typeobject.c:10606
    #20 0x6233e89484cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #21 0x6233e87ec7ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #22 0x6233e8cceb55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #23 0x6233e8cceb55 in _PyEval_Vector ../Python/ceval.c:2001
    #24 0x6233e8953d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #25 0x6233e8953d90 in method_vectorcall ../Objects/classobject.c:95
    #26 0x6233e894effe in _PyVectorcall_Call ../Objects/call.c:273
    #27 0x6233e894effe in _PyObject_Call ../Objects/call.c:348
    #28 0x6233e894effe in PyObject_Call ../Objects/call.c:373
    #29 0x6233e87eeeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #30 0x6233e8cceb55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #31 0x6233e8cceb55 in _PyEval_Vector ../Python/ceval.c:2001
    #32 0x6233e894d623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #33 0x6233e894dcdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #34 0x6233e8b0e444 in call_method ../Objects/typeobject.c:3077
    #35 0x6233e8b0e444 in slot_tp_call ../Objects/typeobject.c:10606
    #36 0x6233e89484cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #37 0x6233e87ebad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #38 0x6233e8cceb55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #39 0x6233e8cceb55 in _PyEval_Vector ../Python/ceval.c:2001
    #40 0x6233e8953d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #41 0x6233e8953d90 in method_vectorcall ../Objects/classobject.c:95
    #42 0x6233e894effe in _PyVectorcall_Call ../Objects/call.c:273
    #43 0x6233e894effe in _PyObject_Call ../Objects/call.c:348
    #44 0x6233e894effe in PyObject_Call ../Objects/call.c:373
    #45 0x6233e87eeeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616

SUMMARY: AddressSanitizer: 4 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

3.15

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140478
* gh-140498
* gh-140499
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
