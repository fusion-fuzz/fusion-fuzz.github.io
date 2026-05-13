# Memory leak in _PyJit_TryInitializeTracing when daemon thread exits

**Issue:** [https://github.com/python/cpython/issues/144068](https://github.com/python/cpython/issues/144068) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-20T11:44:18Z`

**Labels:** `type-bug`, `interpreter-core`, `topic-JIT`

## Description

# Bug report

### Bug description:

```python
import threading
import time

def hot_loop():
    # A hot loop involving function calls (time.time) to trigger 
    # Tier 2 JIT optimization.
    # We run this long enough to ensure it's active during interpreter shutdown.
    end = time.time() + 5.0
    while time.time() < end:
        pass

# 1. Create a daemon thread (crucial: daemon threads are killed/abandoned at shutdown)
t = threading.Thread(target=hot_loop, daemon=True)
t.start()

# 2. Allow brief time for the thread to start and trigger the JIT (Trace/Optimizer)
time.sleep(0.1)

# 3. Exit immediately. 
# The daemon thread is still running. The interpreter shutdown process 
# appears to fail to free the JIT memory allocated for this thread.
```

```
=================================================================
==181062==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 261216 byte(s) in 1 object(s) allocated from:
    #0 0x614025821fb4 in malloc (/home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/python+0x385fb4) (BuildId: 066bbf729257aedd916af3db6dae04834cf3a8ba)
    #1 0x61402634af9e in _PyJit_TryInitializeTracing /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/optimizer.c:1028:58
    #2 0x614025deb313 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/generated_cases.c.h:7705:32
    #3 0x614025db9387 in _PyEval_EvalFrame /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_ceval.h:118:16
    #4 0x614025db9387 in _PyEval_Vector /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:2092:12
    #5 0x614025a33e8f in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_call.h:136:11
    #6 0x614025a31309 in method_vectorcall /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/classobject.c:73:20
    #7 0x614025e76ca2 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_call.h:136:11
    #8 0x614025e76ca2 in context_run /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/context.c:727:29
    #9 0x614025a5397c in method_vectorcall_FASTCALL_KEYWORDS /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/descrobject.c:421:24
    #10 0x614025a2735f in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_call.h:136:11
    #11 0x614025dba4ec in _Py_VectorCallInstrumentation_StackRefSteal /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:762:11
    #12 0x614025df62dd in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/generated_cases.c.h:1788:35
    #13 0x614025db9387 in _PyEval_EvalFrame /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_ceval.h:118:16
    #14 0x614025db9387 in _PyEval_Vector /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/ceval.c:2092:12
    #15 0x614025a33e8f in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Include/internal/pycore_call.h:136:11
    #16 0x614025a31309 in method_vectorcall /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/classobject.c:73:20
    #17 0x614025a29b29 in _PyVectorcall_Call /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Objects/call.c:273:16
    #18 0x6140265bca0a in thread_run /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Modules/_threadmodule.c:387:21
    #19 0x614026424845 in pythread_wrapper /home/fuzz/WorkSpace/FusionFuzzLoop/projects/cpython/cpython/build/../Python/thread_pthread.h:234:5
    #20 0x61402581f896 in asan_thread_start(void*) asan_interceptors.cpp.o

SUMMARY: AddressSanitizer: 261216 byte(s) leaked in 1 allocation(s).
```


### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-144077
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
