# AddressSanitizer: BUS abort in multiprocessing.shared_memory

**Issue:** [https://github.com/python/cpython/issues/140777](https://github.com/python/cpython/issues/140777) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-30T04:26:32Z`

**Labels:** `type-crash`, `pending`

## Description

# Crash report

### What happened?

```python
import multiprocessing
from multiprocessing import shared_memory
original_list = multiprocessing.shared_memory.ShareableList(range(10))
with tempfile.TemporaryDirectory() as d:
    mime_dict = mimetypes.read_mime_types(os_helper.FakePath(file2))
```

```
=================================================================
==2640899==ERROR: AddressSanitizer: BUS on unknown address (pc 0x77784c05ab1c bp 0x7ffe311ba1b0 sp 0x7ffe311ba128 T0)
==2640899==The signal is caused by a WRITE memory access.
==2640899==Hint: this fault was caused by a dereference of a high value address (see register values below).  Disassemble the provided pc to learn which register was used.
    #0 0x77784c05ab1c  (/lib/x86_64-linux-gnu/libc.so.6+0x1a1b1c) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #1 0x77784b50f254 in memset /usr/include/x86_64-linux-gnu/bits/string_fortified.h:59
    #2 0x77784b50f254 in s_pack_internal ../Modules/_struct.c:2106
    #3 0x77784b50fb21 in s_pack_into ../Modules/_struct.c:2315
    #4 0x77784b517b21 in pack_into ../Modules/_struct.c:2539
    #5 0x581c430c378e in _PyVectorcall_Call ../Objects/call.c:273
    #6 0x581c430c378e in _PyObject_Call ../Objects/call.c:348
    #7 0x581c430c378e in PyObject_Call ../Objects/call.c:373
    #8 0x581c42f62e9c in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #9 0x581c4343f785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #10 0x581c4343f785 in _PyEval_Vector ../Python/ceval.c:2005
    #11 0x581c430c1db3 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #12 0x581c430c246c in _PyObject_Call_Prepend ../Objects/call.c:504
    #13 0x581c4326c2e0 in call_method ../Objects/typeobject.c:3077
    #14 0x581c4326c2e0 in slot_tp_init ../Objects/typeobject.c:10835
    #15 0x581c4325e457 in type_call ../Objects/typeobject.c:2461
    #16 0x581c430bcc5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #17 0x581c42f5fad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #18 0x581c4343efb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #19 0x581c4343efb6 in _PyEval_Vector ../Python/ceval.c:2005
    #20 0x581c4343efb6 in PyEval_EvalCode ../Python/ceval.c:888
    #21 0x581c435fd3fe in run_eval_code_obj ../Python/pythonrun.c:1365
    #22 0x581c435fd3fe in run_mod ../Python/pythonrun.c:1459
    #23 0x581c436020a7 in pyrun_file ../Python/pythonrun.c:1293
    #24 0x581c436020a7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #25 0x581c43602bcc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #26 0x581c436753cc in pymain_run_file_obj ../Modules/main.c:410
    #27 0x581c436753cc in pymain_run_file ../Modules/main.c:429
    #28 0x581c436753cc in pymain_run_python ../Modules/main.c:691
    #29 0x581c43676cae in Py_RunMain ../Modules/main.c:772
    #30 0x581c43676cae in pymain_main ../Modules/main.c:802
    #31 0x581c43676cae in Py_BytesMain ../Modules/main.c:826
    #32 0x77784bee31c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #33 0x77784bee328a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: BUS (/lib/x86_64-linux-gnu/libc.so.6+0x1a1b1c) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f) 
==2640899==ABORTING
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
