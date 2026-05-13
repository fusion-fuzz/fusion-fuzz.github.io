# SEGV at Python/generated_cases.c.h _PyEval_EvalFrameDefault in JIT

**Issue:** [https://github.com/python/cpython/issues/142718](https://github.com/python/cpython/issues/142718) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-14T18:35:19Z`

**Labels:** `interpreter-core`, `type-crash`, `topic-JIT`

## Description

# Crash report

### What happened?

```python
class EvilAttr:
    def __init__(self, d):
        self.d = d

    def __del__(self):
        try:
            del self.d['attr']
        except Exception:
            pass

class Obj:
    pass

obj = Obj()
obj.__dict__ = {}

for _ in range(32768):
    obj.attr = EvilAttr(obj.__dict__)
```

```
AddressSanitizer:DEADLYSIGNAL
=================================================================
==1926625==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000008 (pc 0x63b25b676288 bp 0x7fff50d12c70 sp 0x7fff50d120e0 T0)
==1926625==The signal is caused by a READ memory access.
==1926625==Hint: address points to the zero page.
    #0 0x63b25b676288 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h
    #1 0x63b25b663897 in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:119:16
    #2 0x63b25b663897 in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2482:12
    #3 0x63b25b6632b4 in PyEval_EvalCode /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:1008:21
    #4 0x63b25bc639ae in run_eval_code_obj /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1366:12
    #5 0x63b25bc62b7b in run_mod /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1469:19
    #6 0x63b25bc5d17c in pyrun_file /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1294:15
    #7 0x63b25bc5acdc in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:518:13
    #8 0x63b25bc5a04d in _PyRun_AnyFileObject /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:81:15
    #9 0x63b25bcd620a in pymain_run_file_obj /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:410:15
    #10 0x63b25bcd620a in pymain_run_file /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:429:15
    #11 0x63b25bcd42d3 in pymain_run_python /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:691:21
    #12 0x63b25bcd42d3 in Py_RunMain /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:772:5
    #13 0x63b25bcd51d6 in pymain_main /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:802:12
    #14 0x63b25bcd5347 in Py_BytesMain /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:826:12
    #15 0x761d6182a1c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #16 0x761d6182a28a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #17 0x63b25b0274c4 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x2db4c4) (BuildId: e6730b26ad863336dbcafc01d00da0f25ad00b6d)

==1926625==Register values:
rax = 0x0000734d60bffd24  rbx = 0x00007fff50d120e0  rcx = 0x0000000000000001  rdx = 0x0000000000020049  
rdi = 0x0000000000000008  rsi = 0x000074ad60be5220  rbp = 0x00007fff50d12c70  rsp = 0x00007fff50d120e0  
 r8 = 0x0000728d60ccd460   r9 = 0x0000000000000000  r10 = 0x0000000000000001  r11 = 0x00000c764b8c8201  
r12 = 0x00000000000006c6  r13 = 0x000072cd60d207d0  r14 = 0x000074ad60be5280  r15 = 0x0000000000000000  
AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h in _PyEval_EvalFrameDefault
==1926625==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-142762
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
