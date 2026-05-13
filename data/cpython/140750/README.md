# JSON: heap-buffer-overflow in encoder caused by indentation caching

**Issue:** [https://github.com/python/cpython/issues/140750](https://github.com/python/cpython/issues/140750) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-29T11:11:08Z`

**Labels:** `extension-modules`, `type-crash`, `triaged`, `3.14`, `3.15`

## Description

# Crash report

### What happened?

```python
import json

def bad_encoder1(*args):
    return None
enc = json.encoder.c_make_encoder(None, lambda obj: str(obj), bad_encoder1, r'\udcff', ': ', r'\udfff', False, -(2**64), False)    
enc({'spam': 10**1000}, 4)
```

```
=================================================================
==3279101==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x502000004bb0 at pc 0x7079e3b05e0e bp 0x7ffc65d9ea20 sp 0x7ffc65d9ea10
READ of size 8 at 0x502000004bb0 thread T0
    #0 0x7079e3b05e0d in update_indent_cache ../Modules/_json.c:1411
    #1 0x7079e3b05e0d in get_item_separator ../Modules/_json.c:1440
    #2 0x7079e3b1118e in encoder_listencode_dict ../Modules/_json.c:1855
    #3 0x7079e3b1118e in encoder_listencode_obj ../Modules/_json.c:1624
    #4 0x7079e3b121b4 in encoder_call ../Modules/_json.c:1483
    #5 0x5ebc8e985c5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #6 0x5ebc8e828ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #7 0x5ebc8ed07fb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #8 0x5ebc8ed07fb6 in _PyEval_Vector ../Python/ceval.c:2005
    #9 0x5ebc8ed07fb6 in PyEval_EvalCode ../Python/ceval.c:888
    #10 0x5ebc8eec63fe in run_eval_code_obj ../Python/pythonrun.c:1365
    #11 0x5ebc8eec63fe in run_mod ../Python/pythonrun.c:1459
    #12 0x5ebc8eecb0a7 in pyrun_file ../Python/pythonrun.c:1293
    #13 0x5ebc8eecb0a7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #14 0x5ebc8eecbbcc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #15 0x5ebc8ef3e3cc in pymain_run_file_obj ../Modules/main.c:410
    #16 0x5ebc8ef3e3cc in pymain_run_file ../Modules/main.c:429
    #17 0x5ebc8ef3e3cc in pymain_run_python ../Modules/main.c:691
    #18 0x5ebc8ef3fcae in Py_RunMain ../Modules/main.c:772
    #19 0x5ebc8ef3fcae in pymain_main ../Modules/main.c:802
    #20 0x5ebc8ef3fcae in Py_BytesMain ../Modules/main.c:826
    #21 0x7079e43e21c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #22 0x7079e43e228a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

0x502000004bb0 is located 56 bytes after 8-byte region [0x502000004b70,0x502000004b78)
allocated by thread T0 here:
    #0 0x7079e47b0340 in calloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:77
    #1 0x5ebc8ea1cccc in PyList_New ../Objects/listobject.c:262
    #2 0x7079e3b12108 in create_indent_cache ../Modules/_json.c:1393
    #3 0x7079e3b12108 in encoder_call ../Modules/_json.c:1477
    #4 0x5ebc8e985c5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #5 0x5ebc8e828ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #6 0x5ebc8ed07fb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #7 0x5ebc8ed07fb6 in _PyEval_Vector ../Python/ceval.c:2005
    #8 0x5ebc8ed07fb6 in PyEval_EvalCode ../Python/ceval.c:888
    #9 0x5ebc8eec63fe in run_eval_code_obj ../Python/pythonrun.c:1365
    #10 0x5ebc8eec63fe in run_mod ../Python/pythonrun.c:1459
    #11 0x5ebc8eecb0a7 in pyrun_file ../Python/pythonrun.c:1293
    #12 0x5ebc8eecb0a7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #13 0x5ebc8eecbbcc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #14 0x5ebc8ef3e3cc in pymain_run_file_obj ../Modules/main.c:410
    #15 0x5ebc8ef3e3cc in pymain_run_file ../Modules/main.c:429
    #16 0x5ebc8ef3e3cc in pymain_run_python ../Modules/main.c:691
    #17 0x5ebc8ef3fcae in Py_RunMain ../Modules/main.c:772
    #18 0x5ebc8ef3fcae in pymain_main ../Modules/main.c:802
    #19 0x5ebc8ef3fcae in Py_BytesMain ../Modules/main.c:826
    #20 0x7079e43e21c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #21 0x7079e43e228a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

SUMMARY: AddressSanitizer: heap-buffer-overflow ../Modules/_json.c:1411 in update_indent_cache
Shadow bytes around the buggy address:
  0x502000004900: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa
  0x502000004980: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fd
  0x502000004a00: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa
  0x502000004a80: fa fa fd fa fa fa fd fd fa fa fd fa fa fa fd fd
  0x502000004b00: fa fa fd fa fa fa fd fa fa fa fd fa fa fa 00 fa
=>0x502000004b80: fa fa fa fa fa fa[fa]fa fa fa fa fa fa fa fa fa
  0x502000004c00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000004c80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000004d00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000004d80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000004e00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==3279101==ABORTING
```


### CPython versions tested on:

CPython main branch

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
