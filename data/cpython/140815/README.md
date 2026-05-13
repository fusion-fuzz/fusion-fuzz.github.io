# SEGV in `faulthandler.dump_traceback_later`

**Issue:** [https://github.com/python/cpython/issues/140815](https://github.com/python/cpython/issues/140815) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-31T10:07:37Z`

**Labels:** `interpreter-core`, `type-crash`, `triaged`

## Description

# Crash report

### What happened?

```python
import faulthandler
import sys
import unittest

class Test(unittest.TestCase):
    def setUp(self):
        faulthandler.dump_traceback_later(10 * 1e-308, exit=True, file=sys.__stderr__)
    def test_sendall(self):
        os.mkfifo(filename)

if __name__ == '__main__':
    unittest.main()
```

```
FAILED (errors=1)
    #0 0x5646ef225cff in dump_traceback ../Python/traceback.c:1111
    #1 0x5646ef229ae2 in _Py_DumpTracebackThreads ../Python/traceback.c:1302
    #2 0x5646ef2709d4 in faulthandler_thread ../Modules/faulthandler.c:706
    #3 0x5646ef2220af in pythread_wrapper ../Python/thread_pthread.h:234
    #4 0x76c294e77a41 in asan_thread_start ../../../../src/libsanitizer/asan/asan_interceptors.cpp:234
    #5 0x76c294bbaaa3  (/lib/x86_64-linux-gnu/libc.so.6+0x9caa3) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #6 0x76c294c47a33 in __clone (/lib/x86_64-linux-gnu/libc.so.6+0x129a33) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

Address 0x76c292fb39da is located in stack of thread T0 at offset 2522 in frame
    #0 0x5646eeb38bcf in _PyEval_EvalFrameDefault ../Python/ceval.c:1032

  This frame has 37 object(s):
    [32, 36) 'method_found'
    [48, 52) 'level'
    [64, 68) 'handler'
    [80, 84) 'lasti'
    [96, 104) 'temp'
    [128, 136) 'res_o'
    [160, 168) 'match_o'
    [192, 200) 'rest_o'
    [224, 232) 'null_or_index'
    [256, 264) 'null_or_index'
    [288, 296) 'executor'
    [320, 328) 'bc_o'
    [352, 360) 'value_o'
    [384, 392) 'v_o'
    [416, 424) 'retval_o'
    [448, 456) 'ann_dict'
    [480, 488) 'kwnames' (line 1906)
    [512, 528) 'stack'
    [544, 560) 'stack'
    [576, 592) 'args'
    [608, 648) 'stack'
    [688, 752) 'stack_array' (line 1909)
    [784, 872) 'values_o_temp'
    [912, 1000) 'pieces_o_temp'
    [1040, 1128) 'args_o_temp'
    [1168, 1256) 'args_o_temp'
    [1296, 1384) 'args_o_temp'
    [1424, 1512) 'args_o_temp'
    [1552, 1640) 'args_o_temp'
    [1680, 1768) 'args_o_temp'
    [1808, 1896) 'args_o_temp'
    [1936, 2024) 'args_o_temp'
    [2064, 2152) 'args_o_temp'
    [2192, 2280) 'args_o_temp'
    [2320, 2408) 'args_o_temp'
    [2448, 2544) 'entry' (line 1051) <== Memory access at offset 2522 is inside this variable
    [2576, 2656) 'buffer' (line 518)
HINT: this may be a false positive if your program uses some custom stack unwind mechanism, swapcontext or vfork
      (longjmp and C++ exceptions *are* supported)
SUMMARY: AddressSanitizer: stack-use-after-return ../Python/traceback.c:1111 in dump_traceback
Shadow bytes around the buggy address:
  0x76c292fb3700: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3780: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3800: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3880: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3900: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
=>0x76c292fb3980: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5[f5]f5 f5 f5 f5
  0x76c292fb3a00: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3a80: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3b00: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3b80: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
  0x76c292fb3c00: f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5 f5
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
Thread T1 created by T0 here:
    #0 0x76c294f0e1f9 in pthread_create ../../../../src/libsanitizer/asan/asan_interceptors.cpp:245
    #1 0x5646ef22228b in do_start_joinable_thread ../Python/thread_pthread.h:281
    #2 0x5646ef2229a1 in PyThread_start_new_thread ../Python/thread_pthread.h:336
    #3 0x5646ef274706 in faulthandler_dump_traceback_later_impl ../Modules/faulthandler.c:868
    #4 0x5646ef274706 in faulthandler_dump_traceback_later ../Modules/clinic/faulthandler.c.h:366
    #5 0x5646eec9f677 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #6 0x5646eec9f677 in PyObject_Vectorcall ../Objects/call.c:327
    #7 0x5646eeb42bba in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2920
    #8 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #9 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #10 0x5646eeca90f0 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #11 0x5646eeca90f0 in method_vectorcall ../Objects/classobject.c:95
    #12 0x5646eeca478e in _PyVectorcall_Call ../Objects/call.c:273
    #13 0x5646eeca478e in _PyObject_Call ../Objects/call.c:348
    #14 0x5646eeca478e in PyObject_Call ../Objects/call.c:373
    #15 0x5646eeb43e9c in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #16 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #17 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #18 0x5646eeca2db3 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #19 0x5646eeca346c in _PyObject_Call_Prepend ../Objects/call.c:504
    #20 0x5646eee5ff64 in call_method ../Objects/typeobject.c:3077
    #21 0x5646eee5ff64 in slot_tp_call ../Objects/typeobject.c:10606
    #22 0x5646eec9dc5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #23 0x5646eeb417ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #24 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #25 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #26 0x5646eeca90f0 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #27 0x5646eeca90f0 in method_vectorcall ../Objects/classobject.c:95
    #28 0x5646eeca478e in _PyVectorcall_Call ../Objects/call.c:273
    #29 0x5646eeca478e in _PyObject_Call ../Objects/call.c:348
    #30 0x5646eeca478e in PyObject_Call ../Objects/call.c:373
    #31 0x5646eeb43e9c in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #32 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #33 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #34 0x5646eeca2db3 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #35 0x5646eeca346c in _PyObject_Call_Prepend ../Objects/call.c:504
    #36 0x5646eee5ff64 in call_method ../Objects/typeobject.c:3077
    #37 0x5646eee5ff64 in slot_tp_call ../Objects/typeobject.c:10606
    #38 0x5646eec9dc5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #39 0x5646eeb40ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #40 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #41 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #42 0x5646eeca90f0 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #43 0x5646eeca90f0 in method_vectorcall ../Objects/classobject.c:95
    #44 0x5646eeca478e in _PyVectorcall_Call ../Objects/call.c:273
    #45 0x5646eeca478e in _PyObject_Call ../Objects/call.c:348
    #46 0x5646eeca478e in PyObject_Call ../Objects/call.c:373
    #47 0x5646eeb43e9c in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #48 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #49 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #50 0x5646eeca2db3 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #51 0x5646eeca346c in _PyObject_Call_Prepend ../Objects/call.c:504
    #52 0x5646eee5ff64 in call_method ../Objects/typeobject.c:3077
    #53 0x5646eee5ff64 in slot_tp_call ../Objects/typeobject.c:10606
    #54 0x5646eec9dc5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #55 0x5646eeb40ad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #56 0x5646ef020785 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #57 0x5646ef020785 in _PyEval_Vector ../Python/ceval.c:2005
    #58 0x5646eeca2db3 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #59 0x5646eeca346c in _PyObject_Call_Prepend ../Objects/call.c:504
    #60 0x5646eee4d2e0 in call_method ../Objects/typeobject.c:3077
    #61 0x5646eee4d2e0 in slot_tp_init ../Objects/typeobject.c:10835
    #62 0x5646eee3f457 in type_call ../Objects/typeobject.c:2461
    #63 0x5646eec9dc5d in _PyObject_MakeTpCall ../Objects/call.c:242
    #64 0x5646eeb5c9f8 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #65 0x5646ef01ffb6 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #66 0x5646ef01ffb6 in _PyEval_Vector ../Python/ceval.c:2005
    #67 0x5646ef01ffb6 in PyEval_EvalCode ../Python/ceval.c:888
    #68 0x5646ef1de3fe in run_eval_code_obj ../Python/pythonrun.c:1365
    #69 0x5646ef1de3fe in run_mod ../Python/pythonrun.c:1459
    #70 0x5646ef1e30a7 in pyrun_file ../Python/pythonrun.c:1293
    #71 0x5646ef1e30a7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #72 0x5646ef1e3bcc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #73 0x5646ef2563cc in pymain_run_file_obj ../Modules/main.c:410
    #74 0x5646ef2563cc in pymain_run_file ../Modules/main.c:429
    #75 0x5646ef2563cc in pymain_run_python ../Modules/main.c:691
    #76 0x5646ef257cae in Py_RunMain ../Modules/main.c:772
    #77 0x5646ef257cae in pymain_main ../Modules/main.c:802
    #78 0x5646ef257cae in Py_BytesMain ../Modules/main.c:826
    #79 0x76c294b481c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #80 0x76c294b4828a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

==2938816==ABORTING
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140895
* gh-140921
* gh-140981
* gh-140985
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
