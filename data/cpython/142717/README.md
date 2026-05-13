# SEGV race condition with heapq in JIT

**Issue:** [https://github.com/python/cpython/issues/142717](https://github.com/python/cpython/issues/142717) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-12-14T18:29:12Z`

**Labels:** `interpreter-core`, `type-crash`, `topic-JIT`

## Description

# Crash report

### What happened?

```python
import heapq
import threading

# Shared list to corrupt
l = []

def worker():
    # Loop enough times to trigger the race condition
    for _ in range(100000):
        # 1. Mutate list (push)
        heapq.heappush(l, 1)
        
        # 2. Mutate list (pop) - creates conflict with push/read
        try:
            heapq.heappop(l)
        except IndexError:
            pass
            
        # 3. Read access - this triggers the SEGV when the list state is invalid
        try:
            _ = l[0]
        except IndexError:
            pass

# Spawn threads to maximize concurrency
# 8 threads is usually sufficient to trigger the race quickly
threads = [threading.Thread(target=worker) for _ in range(8)]

for t in threads:
    t.start()

for t in threads:
    t.join()
```

```
AddressSanitizer:DEADLYSIGNAL                                                                                                                                                              
=================================================================                                                                                                                          
==1839853==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000008 (pc 0x65224aa17745 bp 0x716acafd5c10 sp 0x716acafd5080 T5)                                                      
==1839853==The signal is caused by a READ memory access.                                                                                                                                   
==1839853==Hint: address points to the zero page.                                                                                                                                          
    #0 0x65224aa17745 in _Py_TYPE_impl /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/object.h:313:16                                                                    
    #1 0x65224aa17745 in _Py_IS_TYPE_impl /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/object.h:328:12                                                                                                                                
    #2 0x65224aa17745 in _PyLong_CheckExactAndCompact /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_long.h:318:12                                                                                                      
    #3 0x65224aa17745 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:697:22                                                                                                              
    #4 0x65224aa00897 in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:119:16                                                                                                                
    #5 0x65224aa00897 in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2482:12                                                                                                                                   
    #6 0x65224a67c46f in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:136:11                                                                                                        
    #7 0x65224a6798e9 in method_vectorcall /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/classobject.c:73:20                                                                                                                           
    #8 0x65224aabca52 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:136:11                                                                                                        
    #9 0x65224aabca52 in context_run /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/context.c:728:29                                                                                                                                     
    #10 0x65224aa030de in _PyCallMethodDescriptorFastWithKeywords_StackRefSteal /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:1189:11                                                                                           
    #11 0x65224aa336f3 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:3439:35                                                                                                            
    #12 0x65224aa00897 in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:119:16                                                                                                               
    #13 0x65224aa00897 in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2482:12                                                                                                                                  
    #14 0x65224a67c46f in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_call.h:136:11                                                                                                       
    #15 0x65224a6798e9 in method_vectorcall /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/classobject.c:73:20                                                                                                                          
    #16 0x65224a672119 in _PyVectorcall_Call /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/call.c:273:16                                                                                                                               
    #17 0x65224b1d992a in thread_run /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/_threadmodule.c:387:21                                                                                                                              
    #18 0x65224b041205 in pythread_wrapper /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/thread_pthread.h:234:5                                                                                                                         
    #19 0x65224a4674ba in asan_thread_start(void*) asan_interceptors.cpp.o                                                   
    #20 0x756ad2d6faa3  (/lib/x86_64-linux-gnu/libc.so.6+0x9caa3) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)                                                                                                                                     
    #21 0x756ad2dfca33 in clone (/lib/x86_64-linux-gnu/libc.so.6+0x129a33) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)                                                                                                                            
                                                                                                                             
==1839853==Register values:                                   
rax = 0x0000000000000008  rbx = 0x0000716acafd5080  rcx = 0x000072bad1fefe84  rdx = 0x0000000000000001                                                                                                                                                    
rdi = 0x000073fad203a3e0  rsi = 0x000073fad203a3b0  rbp = 0x0000716acafd5c10  rsp = 0x0000716acafd5080                                                                                                                                                    
 r8 = 0x000073fad203a3b0   r9 = 0x0000000000000001  r10 = 0x000000000000001a  r11 = 0x0000000000000001                                                                                                                                                    
r12 = 0x00000e7f5a407481  r13 = 0x000073fad203a408  r14 = 0x0000000000000000  r15 = 0x000073fad203a410                                                                                                                                                    
AddressSanitizer can not provide additional info.                                                                            
SUMMARY: AddressSanitizer: SEGV /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/object.h:313:16 in _Py_TYPE_impl                                                                                                                         
Thread T5 created by T0 here:                                 
    #0 0x65224a44dbb5 in pthread_create (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x364bb5) (BuildId: e6730b26ad863336dbcafc01d00da0f25ad00b6d)                                                                                       
    #1 0x65224b03f645 in do_start_joinable_thread /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/thread_pthread.h:281:14                                                                                                                 
    #2 0x65224b03f2b5 in PyThread_start_joinable_thread /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/thread_pthread.h:323:9                                                                                                            
    #3 0x65224b1d8d9f in ThreadHandle_start /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/_threadmodule.c:474:9                                                                                                                        
    #4 0x65224b1d8d9f in do_start_new_thread /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/_threadmodule.c:1920:9                                                                                                                      
    #5 0x65224b1d633f in thread_PyThread_start_joinable_thread /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/_threadmodule.c:2043:14                                                                                                   
    #6 0x65224a7904c4 in cfunction_call /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/methodobject.c:564:18                                                                                                                            
    #7 0x65224a67044a in _PyObject_MakeTpCall /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Objects/call.c:242:18                                                                                                                              
    #8 0x65224aa00e00 in _Py_VectorCall_StackRefSteal /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:1055:11                                                                                                                     
    #9 0x65224aa262f8 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/generated_cases.c.h:2994:35                                                                                                             
    #10 0x65224aa00897 in _PyEval_EvalFrame /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Include/internal/pycore_ceval.h:119:16                                                                                                               
    #11 0x65224aa00897 in _PyEval_Vector /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:2482:12                                                                                                                                  
    #12 0x65224aa002b4 in PyEval_EvalCode /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/ceval.c:1008:21                                                                                                                                 
    #13 0x65224b0009ae in run_eval_code_obj /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1366:12                                                                                                                           
    #14 0x65224afffb7b in run_mod /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1469:19                                                                                                                                     
    #15 0x65224affa17c in pyrun_file /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:1294:15                                                                                                                                  
    #16 0x65224aff7cdc in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:518:13                                                                                                                      
    #17 0x65224aff704d in _PyRun_AnyFileObject /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Python/pythonrun.c:81:15                                                                                                                          
    #18 0x65224b07320a in pymain_run_file_obj /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:410:15                                                                                                                              
    #19 0x65224b07320a in pymain_run_file /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:429:15                                                                                                                                  
    #20 0x65224b0712d3 in pymain_run_python /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:691:21                                                                                                                                
    #21 0x65224b0712d3 in Py_RunMain /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:772:5                                                                                                                                        
    #22 0x65224b0721d6 in pymain_main /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:802:12                                                                                                                                      
    #23 0x65224b072347 in Py_BytesMain /home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/../Modules/main.c:826:12                                                                                                                                     
    #24 0x756ad2cfd1c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)                                                                                                                                     
    #25 0x756ad2cfd28a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)                                                                                                                 
    #26 0x65224a3c44c4 in _start (/home/fuzz/WorkSpace/flowfusion-cpython/cpython/build/python+0x2db4c4) (BuildId: e6730b26ad863336dbcafc01d00da0f25ad00b6d)                                                                                              

==1839853==ABORTING 
```

only reproduced in JIT

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
