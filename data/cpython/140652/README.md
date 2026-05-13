# SEGV in module interpchannels

**Issue:** [https://github.com/python/cpython/issues/140652](https://github.com/python/cpython/issues/140652) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-27T04:11:17Z`

**Labels:** `extension-modules`, `type-crash`, `topic-subinterpreters`, `3.13`, `3.14`, `3.15`

## Description

# Crash report

### What happened?

```python
import unittest
from test.support import import_helper, skip_if_sanitizer
_channels = import_helper.import_module('_interpchannels')
from concurrent.interpreters import _crossinterp
from test.test__interpreters import (
    _interpreters,
)

REPLACE = _crossinterp._UNBOUND_CONSTANT_TO_FLAG[_crossinterp.UNBOUND]

def recv_wait(cid):
        raise ValueError(action)

def clean_up_channels():
    for cid, _, _ in _channels.list_all():
            pass  # already destroyed

class TestBase(unittest.TestCase):
    def tearDown(self):
        clean_up_channels()
        with self.subTest('closed'):
            _channels.recv(cid)
        cid = _channels.create(REPLACE)
        _channels.close(cid)
        excsnap = _interpreters.run_string(id1, dedent(f""))
    def test_close_multiple_times(self):
        cid = _channels.create(REPLACE)
    def test_close_empty(self):
        tests = []

class ChannelReleaseTests(TestBase):
    unittest.main()
```

```
=================================================================
==2066570==ERROR: AddressSanitizer: SEGV on unknown address 0x000000000018 (pc 0x76c08a641e02 bp 0x7fff47d76240 sp 0x7fff47d76110 T0)
==2066570==The signal is caused by a READ memory access.
==2066570==Hint: address points to the zero page.
    #0 0x76c08a641e02 in _channels_list_all ../Modules/_interpchannelsmodule.c:1649
    #1 0x76c08a641e02 in channelsmod_list_all ../Modules/_interpchannelsmodule.c:2996
    #2 0x6427274abee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #3 0x6427274abee7 in PyObject_Vectorcall ../Objects/call.c:327
    #4 0x642727376f25 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #5 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #6 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #7 0x6427274b5d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #8 0x6427274b5d90 in method_vectorcall ../Objects/classobject.c:95
    #9 0x6427274b0ffe in _PyVectorcall_Call ../Objects/call.c:273
    #10 0x6427274b0ffe in _PyObject_Call ../Objects/call.c:348
    #11 0x6427274b0ffe in PyObject_Call ../Objects/call.c:373
    #12 0x642727350eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #13 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #14 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #15 0x6427274af623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #16 0x6427274afcdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #17 0x642727670444 in call_method ../Objects/typeobject.c:3077
    #18 0x642727670444 in slot_tp_call ../Objects/typeobject.c:10606
    #19 0x6427274aa4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #20 0x64272734e7ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #21 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #22 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #23 0x6427274b5d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #24 0x6427274b5d90 in method_vectorcall ../Objects/classobject.c:95
    #25 0x6427274b0ffe in _PyVectorcall_Call ../Objects/call.c:273
    #26 0x6427274b0ffe in _PyObject_Call ../Objects/call.c:348
    #27 0x6427274b0ffe in PyObject_Call ../Objects/call.c:373
    #28 0x642727350eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #29 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #30 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #31 0x6427274af623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #32 0x6427274afcdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #33 0x642727670444 in call_method ../Objects/typeobject.c:3077
    #34 0x642727670444 in slot_tp_call ../Objects/typeobject.c:10606
    #35 0x6427274aa4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #36 0x64272734dad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #37 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #38 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #39 0x6427274b5d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #40 0x6427274b5d90 in method_vectorcall ../Objects/classobject.c:95
    #41 0x6427274b0ffe in _PyVectorcall_Call ../Objects/call.c:273
    #42 0x6427274b0ffe in _PyObject_Call ../Objects/call.c:348
    #43 0x6427274b0ffe in PyObject_Call ../Objects/call.c:373
    #44 0x642727350eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #45 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #46 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #47 0x6427274af623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #48 0x6427274afcdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #49 0x642727670444 in call_method ../Objects/typeobject.c:3077
    #50 0x642727670444 in slot_tp_call ../Objects/typeobject.c:10606
    #51 0x6427274aa4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #52 0x64272734dad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #53 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #54 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #55 0x6427274af623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #56 0x6427274afcdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #57 0x64272765cc50 in call_method ../Objects/typeobject.c:3077
    #58 0x64272765cc50 in slot_tp_init ../Objects/typeobject.c:10835
    #59 0x64272764e9d7 in type_call ../Objects/typeobject.c:2461
    #60 0x6427274aa4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #61 0x642727369a18 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #62 0x642727830b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #63 0x642727830b55 in _PyEval_Vector ../Python/ceval.c:2001
    #64 0x64272781c9e8 in builtin___build_class__ ../Python/bltinmodule.c:205
    #65 0x6427274abee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #66 0x6427274abee7 in PyObject_Vectorcall ../Objects/call.c:327
    #67 0x64272734dad2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #68 0x642727830386 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #69 0x642727830386 in _PyEval_Vector ../Python/ceval.c:2001
    #70 0x642727830386 in PyEval_EvalCode ../Python/ceval.c:884
    #71 0x6427279eef0e in run_eval_code_obj ../Python/pythonrun.c:1365
    #72 0x6427279eef0e in run_mod ../Python/pythonrun.c:1459
    #73 0x6427279f3bb7 in pyrun_file ../Python/pythonrun.c:1293
    #74 0x6427279f3bb7 in _PyRun_SimpleFileObject ../Python/pythonrun.c:521
    #75 0x6427279f46dc in _PyRun_AnyFileObject ../Python/pythonrun.c:81
    #76 0x642727a67afc in pymain_run_file_obj ../Modules/main.c:410
    #77 0x642727a67afc in pymain_run_file ../Modules/main.c:429
    #78 0x642727a67afc in pymain_run_python ../Modules/main.c:691
    #79 0x642727a693de in Py_RunMain ../Modules/main.c:772
    #80 0x642727a693de in pymain_main ../Modules/main.c:802
    #81 0x642727a693de in Py_BytesMain ../Modules/main.c:826
    #82 0x76c08dcd21c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #83 0x76c08dcd228a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV ../Modules/_interpchannelsmodule.c:1649 in _channels_list_all
==2066570==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140656
* gh-143743
* gh-144951
* gh-144953
* gh-144954
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
