# heap-buffer-overflow in ctypes.create_string_buffer _ctypes_test.my_qsort

**Issue:** [https://github.com/python/cpython/issues/140409](https://github.com/python/cpython/issues/140409) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-21T10:30:02Z`

**Labels:** N/A

## Description

# Crash report

### What happened?

```python
import unittest
from ctypes import CDLL, CFUNCTYPE, POINTER, create_string_buffer, sizeof, c_void_p, c_char, c_int, c_double, c_size_t
from test.support import import_helper
_ctypes_test = import_helper.import_module('_ctypes_test')
lib = CDLL(_ctypes_test.__file__)
def three_way_cmp(x, y):
    return (x > y) - (x < y)
class LibTest(unittest.TestCase):
        comparefunc = CFUNCTYPE(c_int, POINTER(c_char), POINTER(c_char))
        def sort(a, b):
            return three_way_cmp(a[0], b[4096])
        chars = create_string_buffer(b'spam, spam, and spam')
        lib.my_qsort(chars, len(chars) - 1, sizeof(c_char), comparefunc(sort))
if __name__ == '__main__':
    unittest.main()
```

```
=================================================================
==402117==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x503000062091 at pc 0x5d1621835367 bp 0x7ffe643c19f0 sp 0x7ffe643c19e0
READ of size 1 at 0x503000062091 thread T0
    #0 0x5d1621835366 in PyBytes_FromStringAndSize ../Objects/bytesobject.c:148
    #1 0x73ed428585de in Pointer_item_lock_held ../Modules/_ctypes/_ctypes.c:5583
    #2 0x5d162180363c in PyObject_GetItem ../Objects/abstract.c:163
    #3 0x5d16216ef481 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:62
    #4 0x5d1621bd1bb5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #5 0x5d1621bd1bb5 in _PyEval_Vector ../Python/ceval.c:2001
    #6 0x5d16218531a7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #7 0x5d16218531a7 in PyObject_Vectorcall ../Objects/call.c:327
    #8 0x73ed4285aba8 in _CallPythonObject ../Modules/_ctypes/callbacks.c:201
    #9 0x73ed4285b03c in closure_fcn ../Modules/_ctypes/callbacks.c:293
    #10 0x73ed45516640  (/lib/x86_64-linux-gnu/libffi.so.8+0x7640) (BuildId: c9149b6e99105aa4321ddd4a10ee4b90de7b7d49)
    #11 0x73ed45516d37  (/lib/x86_64-linux-gnu/libffi.so.8+0x7d37) (BuildId: c9149b6e99105aa4321ddd4a10ee4b90de7b7d49)
    #12 0x73ed45fb00a2 in qsort_r ../../../../src/libsanitizer/sanitizer_common/sanitizer_common_interceptors.inc:10019
    #13 0x73ed45516b15  (/lib/x86_64-linux-gnu/libffi.so.8+0x7b15) (BuildId: c9149b6e99105aa4321ddd4a10ee4b90de7b7d49)
    #14 0x73ed455133ee  (/lib/x86_64-linux-gnu/libffi.so.8+0x43ee) (BuildId: c9149b6e99105aa4321ddd4a10ee4b90de7b7d49)
    #15 0x73ed455160bd in ffi_call (/lib/x86_64-linux-gnu/libffi.so.8+0x70bd) (BuildId: c9149b6e99105aa4321ddd4a10ee4b90de7b7d49)
    #16 0x73ed428608d0 in _call_function_pointer ../Modules/_ctypes/callproc.c:945
    #17 0x73ed428608d0 in _ctypes_callproc ../Modules/_ctypes/callproc.c:1311
    #18 0x73ed42852646 in PyCFuncPtr_call ../Modules/_ctypes/_ctypes.c:4685
    #19 0x5d162185178d in _PyObject_MakeTpCall ../Objects/call.c:242
    #20 0x5d16216f5b82 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #21 0x5d1621bd1bb5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #22 0x5d1621bd1bb5 in _PyEval_Vector ../Python/ceval.c:2001
    #23 0x5d1621bbda48 in builtin___build_class__ ../Python/bltinmodule.c:205
    #24 0x5d16218531a7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #25 0x5d16218531a7 in PyObject_Vectorcall ../Objects/call.c:327
    #26 0x5d16216f5b82 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #27 0x5d1621bd13e6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #28 0x5d1621bd13e6 in _PyEval_Vector ../Python/ceval.c:2001
    #29 0x5d1621bd13e6 in PyEval_EvalCode ../Python/ceval.c:884
    #30 0x5d1621d16cce in run_eval_code_obj ../Python/pythonrun.c:1365
    #31 0x5d1621d16cce in run_mod ../Python/pythonrun.c:1459
    #32 0x5d1621d1b977 in pyrun_file ../Python/pythonrun.c:1293
    #33 0x5d1621d1b977 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #34 0x5d1621d1c49c in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #35 0x5d1621d8f7fc in pymain_run_file_obj ../Modules/main.c:410
    #36 0x5d1621d8f7fc in pymain_run_file ../Modules/main.c:429
    #37 0x5d1621d8f7fc in pymain_run_python ../Modules/main.c:691
    #38 0x5d1621d910de in Py_RunMain ../Modules/main.c:772
    #39 0x5d1621d910de in pymain_main ../Modules/main.c:802
    #40 0x5d1621d910de in Py_BytesMain ../Modules/main.c:826
    #41 0x73ed45c6e1c9 in __libc_start_call_main ../sysdeps/nptl/libc_start_call_main.h:58
    #42 0x73ed45c6e28a in __libc_start_main_impl ../csu/libc-start.c:360
    #43 0x5d162172b524 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython-normal/build/python+0x20e524) (BuildId: b922665a0e7afc8ee52df7c3eac25a643025109e)

0x503000062091 is located 4076 bytes after 21-byte region [0x503000061090,0x5030000610a5)
allocated by thread T0 here:
    #0 0x73ed4603c9c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x73ed428426e4 in PyCData_MallocBuffer ../Modules/_ctypes/_ctypes.c:3271
    #2 0x73ed428426e4 in generic_pycdata_new ../Modules/_ctypes/_ctypes.c:3589
    #3 0x73ed428426e4 in GenericPyCData_new ../Modules/_ctypes/_ctypes.c:3559
    #4 0x5d16219efe78 in type_call ../Objects/typeobject.c:2448
    #5 0x5d162185178d in _PyObject_MakeTpCall ../Objects/call.c:242
    #6 0x5d1621711388 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #7 0x5d1621bd1bb5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #8 0x5d1621bd1bb5 in _PyEval_Vector ../Python/ceval.c:2001
    #9 0x5d1621bbda48 in builtin___build_class__ ../Python/bltinmodule.c:205
    #10 0x5d16218531a7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x5d16218531a7 in PyObject_Vectorcall ../Objects/call.c:327
    #12 0x5d16216f5b82 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #13 0x5d1621bd13e6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #14 0x5d1621bd13e6 in _PyEval_Vector ../Python/ceval.c:2001
    #15 0x5d1621bd13e6 in PyEval_EvalCode ../Python/ceval.c:884
    #16 0x5d1621d16cce in run_eval_code_obj ../Python/pythonrun.c:1365
    #17 0x5d1621d16cce in run_mod ../Python/pythonrun.c:1459
    #18 0x5d1621d1b977 in pyrun_file ../Python/pythonrun.c:1293
    #19 0x5d1621d1b977 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #20 0x5d1621d1c49c in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #21 0x5d1621d8f7fc in pymain_run_file_obj ../Modules/main.c:410
    #22 0x5d1621d8f7fc in pymain_run_file ../Modules/main.c:429
    #23 0x5d1621d8f7fc in pymain_run_python ../Modules/main.c:691
    #24 0x5d1621d910de in Py_RunMain ../Modules/main.c:772
    #25 0x5d1621d910de in pymain_main ../Modules/main.c:802
    #26 0x5d1621d910de in Py_BytesMain ../Modules/main.c:826
    #27 0x73ed45c6e1c9 in __libc_start_call_main ../sysdeps/nptl/libc_start_call_main.h:58
    #28 0x73ed45c6e28a in __libc_start_main_impl ../csu/libc-start.c:360
    #29 0x5d162172b524 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython-normal/build/python+0x20e524) (BuildId: b922665a0e7afc8ee52df7c3eac25a643025109e)

SUMMARY: AddressSanitizer: heap-buffer-overflow ../Objects/bytesobject.c:148 in PyBytes_FromStringAndSize
Shadow bytes around the buggy address:
  0x503000061e00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000061e80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000061f00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000061f80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000062000: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
=>0x503000062080: fa fa[fa]fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000062100: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000062180: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000062200: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000062280: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x503000062300: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==402117==ABORTING
```

### CPython versions tested on:

3.15

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
