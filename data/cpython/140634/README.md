# heap-buffer-overflow deepcopy posix_param

**Issue:** [https://github.com/python/cpython/issues/140634](https://github.com/python/cpython/issues/140634) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-26T15:21:06Z`

**Labels:** `extension-modules`, `type-crash`, `3.13`, `3.14`, `3.15`

## Description

# Crash report

### What happened?

```python
import copy
import posix

param = posix.sched_param(float('inf'))
newparam = copy.deepcopy(param)
```

```
=================================================================
==2451226==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x503000014d9f at pc 0x6030c15f984b bp 0x7fffcd1a09a0 sp 0x7fffcd1a0990
READ of size 8 at 0x503000014d9f thread T0
    #0 0x6030c15f984a in _PyFreeList_PopNoStats ../Include/internal/pycore_freelist.h:79
    #1 0x6030c15f984a in clear_freelist ../Objects/object.c:901
    #2 0x6030c15f984a in _PyObject_ClearFreeLists ../Objects/object.c:925
    #3 0x6030c18e1786 in gc_collect_full ../Python/gc.c:1735
    #4 0x6030c18e1786 in _PyGC_Collect ../Python/gc.c:2098
    #5 0x6030c197c98d in finalize_modules ../Python/pylifecycle.c:1755
    #6 0x6030c1986863 in _Py_Finalize ../Python/pylifecycle.c:2255
    #7 0x6030c1a100e3 in Py_RunMain ../Modules/main.c:774
    #8 0x6030c1a100e3 in pymain_main ../Modules/main.c:802
    #9 0x6030c1a100e3 in Py_BytesMain ../Modules/main.c:826
    #10 0x70dd8b5631c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #11 0x70dd8b56328a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

0x503000014d9f is located 1 bytes before 24-byte region [0x503000014da0,0x503000014db8)
allocated by thread T0 here:
    #0 0x70dd8b9319c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x6030c153a1d9 in PyFloat_FromDouble ../Objects/floatobject.c:128
    #2 0x6030c1a49ac1 in fill_time ../Modules/posixmodule.c:2681
    #3 0x6030c1a4a1de in _pystat_fromstructstat ../Modules/posixmodule.c:2796
    #4 0x6030c1a4bffc in posix_do_stat ../Modules/posixmodule.c:2918
    #5 0x6030c1a5670c in os_stat_impl ../Modules/posixmodule.c:3285
    #6 0x6030c1a5670c in os_stat ../Modules/clinic/posixmodule.c.h:105
    #7 0x6030c13997e6 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2361
    #8 0x6030c1850bb5 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #9 0x6030c1850bb5 in _PyEval_Vector ../Python/ceval.c:2001
    #10 0x6030c14d1322 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x6030c14d1322 in object_vacall ../Objects/call.c:819
    #12 0x6030c14d4971 in PyObject_CallMethodObjArgs ../Objects/call.c:886
    #13 0x6030c1918b73 in import_find_and_load ../Python/import.c:3701
    #14 0x6030c1918b73 in PyImport_ImportModuleLevelObject ../Python/import.c:3783
    #15 0x6030c18333cc in builtin___import___impl ../Python/bltinmodule.c:285
    #16 0x6030c18333cc in builtin___import__ ../Python/clinic/bltinmodule.c.h:110
    #17 0x6030c14d1be8 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #18 0x6030c14d1be8 in _PyObject_CallFunctionVa ../Objects/call.c:552
    #19 0x6030c14d2c79 in PyObject_CallFunction ../Objects/call.c:574
    #20 0x6030c191a0ab in PyImport_Import ../Python/import.c:3975
    #21 0x6030c191a85f in PyImport_ImportModule ../Python/import.c:3423
    #22 0x6030c185bd42 in _PyCodec_InitRegistry ../Python/codecs.c:1686
    #23 0x6030c1772094 in _PyUnicode_InitEncodings ../Objects/unicodeobject.c:15455
    #24 0x6030c198082b in init_interp_main ../Python/pylifecycle.c:1228
    #25 0x6030c19843cc in pyinit_main ../Python/pylifecycle.c:1420
    #26 0x6030c19843cc in Py_InitializeFromConfig ../Python/pylifecycle.c:1451
    #27 0x6030c1a0bcd9 in pymain_init ../Modules/main.c:68
    #28 0x6030c1a10062 in pymain_main ../Modules/main.c:793
    #29 0x6030c1a10062 in Py_BytesMain ../Modules/main.c:826
    #30 0x70dd8b5631c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #31 0x70dd8b56328a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

SUMMARY: AddressSanitizer: heap-buffer-overflow ../Include/internal/pycore_freelist.h:79 in _PyFreeList_PopNoStats
Shadow bytes around the buggy address:
  0x503000014b00: fd fd fd fd fa fa fd fd fd fd fa fa fd fd fd fd
  0x503000014b80: fa fa fd fd fd fd fa fa fd fd fd fd fa fa fd fd
  0x503000014c00: fd fd fa fa fd fd fd fd fa fa fd fd fd fd fa fa
  0x503000014c80: fd fd fd fd fa fa fd fd fd fd fa fa fd fd fd fd
  0x503000014d00: fa fa fd fd fd fd fa fa fd fd fd fd fa fa fd fd
=>0x503000014d80: fd fd fa[fa]00 00 00 fa fa fa fd fd fd fa fa fa
  0x503000014e00: fd fd fd fd fa fa fd fd fd fa fa fa fd fd fd fd
  0x503000014e80: fa fa fd fd fd fd fa fa fd fd fd fd fa fa fd fd
  0x503000014f00: fd fd fa fa fd fd fd fd fa fa fd fd fd fd fa fa
  0x503000014f80: fd fd fd fd fa fa fd fd fd fd fa fa fd fd fd fd
  0x503000015000: fa fa fd fd fd fd fa fa fd fd fd fd fa fa fd fd
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
==2451226==ABORTING
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140667
* gh-140685
* gh-140686
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
