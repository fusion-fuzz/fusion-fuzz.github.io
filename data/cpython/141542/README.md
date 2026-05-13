# memory leak in `_PyJit_TryInitializeTracing`

**Issue:** [https://github.com/python/cpython/issues/141542](https://github.com/python/cpython/issues/141542) &nbsp;·&nbsp; **State:** `open` &nbsp;·&nbsp; **Created:** `2025-11-14T00:59:47Z`

**Labels:** `type-bug`, `interpreter-core`, `topic-JIT`

## Description

# Bug report

### Bug description:

```python
import threading
import time
import unittest
class TestCpuModeFiltering(unittest.TestCase):
        def idle_worker():
            try:
                time.sleep(5)
            except Exception:
                return
        def cpu_active_worker():
            end = time.time() + 0.1
            x = 0
            while time.time() < end:
                x += 1
        cpu_thread = threading.Thread(target=cpu_active_worker, name="cpu_active_worker", daemon=True)
        cpu_thread.start()
        self.assertIn('idle_worker', wall_mode_output)
if __name__ == "__main__":
    unittest.main()
```

```
=================================================================
==2566930==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 72000 byte(s) in 1 object(s) allocated from:
    #0 0x5ceb3b3f4c38 in malloc (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x35fc38) (BuildId: 1f588d55837e5ca248154490b63acc5259fe73cf)
    #1 0x5ceb3bc6ac41 in _PyJit_TryInitializeTracing /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/optimizer.c:981:70
    #2 0x5ceb3b9bd742 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:7660:32
    #3 0x5ceb3b989f0a in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:121:16
    #4 0x5ceb3b989f0a in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2111:12
    #5 0x5ceb3b6076ef in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:169:11
    #6 0x5ceb3b604b69 in method_vectorcall /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/classobject.c:73:20
    #7 0x5ceb3ba57092 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:169:11
    #8 0x5ceb3ba57092 in context_run /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/context.c:728:29
    #9 0x5ceb3b627143 in method_vectorcall_FASTCALL_KEYWORDS /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/descrobject.c:421:24
    #10 0x5ceb3b5fa6ff in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:169:11
    #11 0x5ceb3b9cd870 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:1620:35
    #12 0x5ceb3b989f0a in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:121:16
    #13 0x5ceb3b989f0a in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2111:12
    #14 0x5ceb3b6076ef in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:169:11
    #15 0x5ceb3b604b69 in method_vectorcall /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/classobject.c:73:20
    #16 0x5ceb3b5fcea9 in _PyVectorcall_Call /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/call.c:273:16
    #17 0x5ceb3bed35fa in thread_run /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/_threadmodule.c:387:21
    #18 0x5ceb3bd3ba75 in pythread_wrapper /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/thread_pthread.h:234:5
    #19 0x5ceb3b3f24ba in asan_thread_start(void*) asan_interceptors.cpp.o

SUMMARY: AddressSanitizer: 72000 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
