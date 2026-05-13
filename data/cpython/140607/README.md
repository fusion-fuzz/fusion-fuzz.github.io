# heap-buffer-overflow in _io__RawIOBase_read

**Issue:** [https://github.com/python/cpython/issues/140607](https://github.com/python/cpython/issues/140607) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-26T03:05:45Z`

**Labels:** `interpreter-core`, `topic-IO`, `type-crash`, `3.13`, `3.14`, `3.15`

## Description

# Crash report

### What happened?

```python
import io
import unittest
class CTestCase(unittest.TestCase):
    pass
class BufferedReaderTest:
    read_mode = 'rb'
class MockRaw(io.RawIOBase):
    def __init__(self, data=r'\n\r\t'):
        self._buf = memoryview(data)
        self._pos = 0
    def readable(self):
        return True
    def readinto(self, b):
        if self._pos >= len(self._buf):
            return 2147483647
        n = min(len(b), len(self._buf) - self._pos)
        self._pos += n
        return n
class CBufferedReaderTest(BufferedReaderTest, CTestCase):
    tp = io.BufferedReader
    def test_initialization(self):
        rawio = MockRaw(b'abc')
        bufio = self.tp(rawio)
        self.assertEqual(bufio.read(), b'abc')
if __name__ == "__main__":
    unittest.main()
```

```
=================================================================
==2664130==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x73a39fb97801 at pc 0x73a3a346142e bp 0x7fff799565e0 sp 0x7fff79955d88
READ of size 2147483647 at 0x73a39fb97801 thread T0
    #0 0x73a3a346142d in memcpy ../../../../src/libsanitizer/sanitizer_common/sanitizer_common_interceptors_memintrinsics.inc:115
    #1 0x5b58cf248051 in memcpy /usr/include/x86_64-linux-gnu/bits/string_fortified.h:29
    #2 0x5b58cf248051 in PyBytes_FromStringAndSize ../Objects/bytesobject.c:162
    #3 0x5b58cf8d7adb in _io__RawIOBase_read_impl ../Modules/_io/iobase.c:949
    #4 0x5b58cf8d7adb in _io__RawIOBase_read ../Modules/_io/clinic/iobase.c.h:423
    #5 0x5b58cf265928 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #6 0x5b58cf265928 in _PyObject_CallFunctionVa ../Objects/call.c:552
    #7 0x5b58cf2675f0 in callmethod ../Objects/call.c:626
    #8 0x5b58cf2675f0 in _PyObject_CallMethod ../Objects/call.c:694
    #9 0x5b58cf8d7648 in _io__RawIOBase_readall_impl ../Modules/_io/iobase.c:971
    #10 0x5b58cf8d7648 in _io__RawIOBase_readall ../Modules/_io/clinic/iobase.c.h:444
    #11 0x5b58cf8eaee4 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #12 0x5b58cf8eaee4 in _PyObject_CallNoArgs ../Include/internal/pycore_call.h:185
    #13 0x5b58cf8eaee4 in _bufferedreader_read_all ../Modules/_io/bufferedio.c:1706
    #14 0x5b58cf8eaee4 in _io__Buffered_read_impl ../Modules/_io/bufferedio.c:1002
    #15 0x5b58cf8eaee4 in _io__Buffered_read ../Modules/_io/clinic/bufferedio.c.h:677
    #16 0x5b58cf265ee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #17 0x5b58cf265ee7 in PyObject_Vectorcall ../Objects/call.c:327
    #18 0x5b58cf107ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #19 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #20 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #21 0x5b58cf26fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #22 0x5b58cf26fd90 in method_vectorcall ../Objects/classobject.c:95
    #23 0x5b58cf26affe in _PyVectorcall_Call ../Objects/call.c:273
    #24 0x5b58cf26affe in _PyObject_Call ../Objects/call.c:348
    #25 0x5b58cf26affe in PyObject_Call ../Objects/call.c:373
    #26 0x5b58cf10aeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #27 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #28 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #29 0x5b58cf269623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #30 0x5b58cf269cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #31 0x5b58cf42a444 in call_method ../Objects/typeobject.c:3077
    #32 0x5b58cf42a444 in slot_tp_call ../Objects/typeobject.c:10606
    #33 0x5b58cf2644cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #34 0x5b58cf1087ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #35 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #36 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #37 0x5b58cf26fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #38 0x5b58cf26fd90 in method_vectorcall ../Objects/classobject.c:95
    #39 0x5b58cf26affe in _PyVectorcall_Call ../Objects/call.c:273
    #40 0x5b58cf26affe in _PyObject_Call ../Objects/call.c:348
    #41 0x5b58cf26affe in PyObject_Call ../Objects/call.c:373
    #42 0x5b58cf10aeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #43 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #44 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #45 0x5b58cf269623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #46 0x5b58cf269cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #47 0x5b58cf42a444 in call_method ../Objects/typeobject.c:3077
    #48 0x5b58cf42a444 in slot_tp_call ../Objects/typeobject.c:10606
    #49 0x5b58cf2644cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #50 0x5b58cf107ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #51 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #52 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #53 0x5b58cf26fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #54 0x5b58cf26fd90 in method_vectorcall ../Objects/classobject.c:95
    #55 0x5b58cf26affe in _PyVectorcall_Call ../Objects/call.c:273
    #56 0x5b58cf26affe in _PyObject_Call ../Objects/call.c:348
    #57 0x5b58cf26affe in PyObject_Call ../Objects/call.c:373
    #58 0x5b58cf10aeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #59 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #60 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #61 0x5b58cf269623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #62 0x5b58cf269cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #63 0x5b58cf42a444 in call_method ../Objects/typeobject.c:3077
    #64 0x5b58cf42a444 in slot_tp_call ../Objects/typeobject.c:10606
    #65 0x5b58cf2644cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #66 0x5b58cf107ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #67 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #68 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #69 0x5b58cf269623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #70 0x5b58cf269cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #71 0x5b58cf416c50 in call_method ../Objects/typeobject.c:3077
    #72 0x5b58cf416c50 in slot_tp_init ../Objects/typeobject.c:10835
    #73 0x5b58cf4089d7 in type_call ../Objects/typeobject.c:2461
    #74 0x5b58cf2644cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #75 0x5b58cf123a18 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #76 0x5b58cf5ea386 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #77 0x5b58cf5ea386 in _PyEval_Vector ../Python/ceval.c:2001
    #78 0x5b58cf5ea386 in PyEval_EvalCode ../Python/ceval.c:884
    #79 0x5b58cf7a8f0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #80 0x5b58cf7a8f0e in run_mod ../Python/pythonrun.c:1459
    #81 0x5b58cf7adbb7 in pyrun_file ../Python/pythonrun.c:1293
    #82 0x5b58cf7adbb7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #83 0x5b58cf7ae6dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #84 0x5b58cf821afc in pymain_run_file_obj ../Modules/main.c:410
    #85 0x5b58cf821afc in pymain_run_file ../Modules/main.c:429
    #86 0x5b58cf821afc in pymain_run_python ../Modules/main.c:691
    #87 0x5b58cf8233de in Py_RunMain ../Modules/main.c:772
    #88 0x5b58cf8233de in pymain_main ../Modules/main.c:802
    #89 0x5b58cf8233de in Py_BytesMain ../Modules/main.c:826
    #90 0x73a3a30951c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #91 0x73a3a309528a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #92 0x5b58cf13dfa4 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x21afa4) (BuildId: f28384d3eff6aa8d5f0c5730194edf28c0f6b3bd)

0x73a39fb97801 is located 0 bytes after 131073-byte region [0x73a39fb77800,0x73a39fb97801)
allocated by thread T0 here:
    #0 0x73a3a34639c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x5b58cf23550c in PyByteArray_FromStringAndSize ../Objects/bytearrayobject.c:153
    #2 0x5b58cf8d7a18 in _io__RawIOBase_read_impl ../Modules/_io/iobase.c:932
    #3 0x5b58cf8d7a18 in _io__RawIOBase_read ../Modules/_io/clinic/iobase.c.h:423
    #4 0x5b58cf265928 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #5 0x5b58cf265928 in _PyObject_CallFunctionVa ../Objects/call.c:552
    #6 0x5b58cf2675f0 in callmethod ../Objects/call.c:626
    #7 0x5b58cf2675f0 in _PyObject_CallMethod ../Objects/call.c:694
    #8 0x5b58cf8d7648 in _io__RawIOBase_readall_impl ../Modules/_io/iobase.c:971
    #9 0x5b58cf8d7648 in _io__RawIOBase_readall ../Modules/_io/clinic/iobase.c.h:444
    #10 0x5b58cf8eaee4 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x5b58cf8eaee4 in _PyObject_CallNoArgs ../Include/internal/pycore_call.h:185
    #12 0x5b58cf8eaee4 in _bufferedreader_read_all ../Modules/_io/bufferedio.c:1706
    #13 0x5b58cf8eaee4 in _io__Buffered_read_impl ../Modules/_io/bufferedio.c:1002
    #14 0x5b58cf8eaee4 in _io__Buffered_read ../Modules/_io/clinic/bufferedio.c.h:677
    #15 0x5b58cf265ee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #16 0x5b58cf265ee7 in PyObject_Vectorcall ../Objects/call.c:327
    #17 0x5b58cf107ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #18 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #19 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #20 0x5b58cf26fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #21 0x5b58cf26fd90 in method_vectorcall ../Objects/classobject.c:95
    #22 0x5b58cf26affe in _PyVectorcall_Call ../Objects/call.c:273
    #23 0x5b58cf26affe in _PyObject_Call ../Objects/call.c:348
    #24 0x5b58cf26affe in PyObject_Call ../Objects/call.c:373
    #25 0x5b58cf10aeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #26 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #27 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #28 0x5b58cf269623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #29 0x5b58cf269cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #30 0x5b58cf42a444 in call_method ../Objects/typeobject.c:3077
    #31 0x5b58cf42a444 in slot_tp_call ../Objects/typeobject.c:10606
    #32 0x5b58cf2644cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #33 0x5b58cf1087ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #34 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #35 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #36 0x5b58cf26fd90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #37 0x5b58cf26fd90 in method_vectorcall ../Objects/classobject.c:95
    #38 0x5b58cf26affe in _PyVectorcall_Call ../Objects/call.c:273
    #39 0x5b58cf26affe in _PyObject_Call ../Objects/call.c:348
    #40 0x5b58cf26affe in PyObject_Call ../Objects/call.c:373
    #41 0x5b58cf10aeb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #42 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #43 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001
    #44 0x5b58cf269623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #45 0x5b58cf269cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #46 0x5b58cf42a444 in call_method ../Objects/typeobject.c:3077
    #47 0x5b58cf42a444 in slot_tp_call ../Objects/typeobject.c:10606
    #48 0x5b58cf2644cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #49 0x5b58cf107ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #50 0x5b58cf5eab55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #51 0x5b58cf5eab55 in _PyEval_Vector ../Python/ceval.c:2001

SUMMARY: AddressSanitizer: heap-buffer-overflow ../../../../src/libsanitizer/sanitizer_common/sanitizer_common_interceptors_memintrinsics.inc:115 in memcpy
Shadow bytes around the buggy address:
  0x73a39fb97580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x73a39fb97600: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x73a39fb97680: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x73a39fb97700: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x73a39fb97780: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x73a39fb97800:[01]fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x73a39fb97880: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x73a39fb97900: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x73a39fb97980: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x73a39fb97a00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x73a39fb97a80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==2664130==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140610
* gh-140611
* gh-140728
* gh-140730
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
