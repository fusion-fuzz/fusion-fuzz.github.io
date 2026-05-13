# heap-use-after-free `_elementtree_XMLParser__setevents_impl`

**Issue:** [https://github.com/python/cpython/issues/139210](https://github.com/python/cpython/issues/139210) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-09-21T15:33:01Z`

**Labels:** `type-bug`, `extension-modules`, `topic-XML`, `3.14`

## Description

# Bug report

### Bug description:

```python
import gettext
import io
import xml.etree.ElementTree as ET

A_context_unicode = '按钮'
A_message_unicode = '确定'
A_result_unicode = gettext.pgettext(A_context_unicode, A_message_unicode)
fusion = A_result_unicode
B_xml_data = b'<?xml version="1.0"?>\n<root>\n  <child name="a">Text1</child>\n  <child name="b">Text2</child>\n</root>'
B_f = io.BytesIO(B_xml_data)
B_result = list(ET.iterparse(B_f, events=fusion))
```

config: `--enable-experimental-jit=yes --with-address-sanitizer`

```
==1106491==ERROR: AddressSanitizer: heap-use-after-free on address 0x502000005ef0 at pc 0x5efb246dbfe7 bp 0x7fffacd3add0 sp 0x7fffacd3a598
READ of size 3 at 0x502000005ef0 thread T0
    #0 0x5efb246dbfe6 in strlen (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x1e4fe6) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5)
    #1 0x5efb24a73efc in unicode_fromformat_write_utf8 /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:2702:18
    #2 0x5efb24a2fc62 in unicode_fromformat_arg /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c
    #3 0x5efb24a2fc62 in unicode_from_format /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:3211:17
    #4 0x5efb24a2e4b5 in PyUnicode_FromFormatV /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:3245:9
    #5 0x5efb24bf20bf in _PyErr_FormatV /home/fuzz/WorkSpace/PyFuzz/cpython/Python/errors.c:1208:14
    #6 0x5efb24bf20bf in PyErr_Format /home/fuzz/WorkSpace/PyFuzz/cpython/Python/errors.c:1243:5
    #7 0x735d1c93bc4e in _elementtree_XMLParser__setevents_impl /home/fuzz/WorkSpace/PyFuzz/cpython/./Modules/_elementtree.c:4218:13
    #8 0x735d1c93bc4e in _elementtree_XMLParser__setevents /home/fuzz/WorkSpace/PyFuzz/cpython/./Modules/clinic/_elementtree.c.h:1329:20
    #9 0x5efb2489c462 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_call.h:169:11
    #10 0x5efb2489c462 in PyObject_Vectorcall /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:327:12
    #11 0x5efb24b6a914 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/PyFuzz/cpython/Python/generated_cases.c.h:1620:35
    #12 0x5efb24b5afe4 in _PyEval_EvalFrame /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_ceval.h:121:16
    #13 0x5efb24b5afe4 in _PyEval_Vector /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:1990:12
    #14 0x5efb2489ad15 in _PyObject_VectorcallDictTstate /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:146:15
    #15 0x5efb2489cf7e in _PyObject_Call_Prepend /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:504:24
    #16 0x5efb249fbf90 in call_method /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:3076:19
    #17 0x5efb24a0d7ad in slot_tp_init /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:10828:21
    #18 0x5efb249e90d4 in type_call /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:2460:19
    #19 0x5efb2489b1c2 in _PyObject_MakeTpCall /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:242:18
    #20 0x5efb24b721ff in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/PyFuzz/cpython/Python/generated_cases.c.h:2920:35
    #21 0x5efb24b5a980 in _PyEval_EvalFrame /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_ceval.h:121:16
    #22 0x5efb24b5a980 in _PyEval_Vector /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:1990:12
    #23 0x5efb24b5a980 in PyEval_EvalCode /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:873:21
    #24 0x5efb24d15ca8 in run_eval_code_obj /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1365:12
    #25 0x5efb24d15ca8 in run_mod /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1459:19
    #26 0x5efb24d0fd3f in pyrun_file /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1293:15
    #27 0x5efb24d0fd3f in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:521:13
    #28 0x5efb24d0f335 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:81:15
    #29 0x5efb24d7f5a5 in pymain_run_file_obj /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:410:15
    #30 0x5efb24d7f5a5 in pymain_run_file /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:429:15
    #31 0x5efb24d7df5b in pymain_run_python /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:691:21
    #32 0x5efb24d7df5b in Py_RunMain /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:772:5
    #33 0x5efb24d7ea1d in pymain_main /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:802:12
    #34 0x5efb24d7eb83 in Py_BytesMain /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:826:12
    #35 0x735d1ed861c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #36 0x735d1ed8628a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #37 0x5efb246c40f4 in _start (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x1cd0f4) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5)

0x502000005ef0 is located 0 bytes inside of 4-byte region [0x502000005ef0,0x502000005ef4)
freed by thread T0 here:
    #0 0x5efb24763c8a in free (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x26cc8a) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5)
    #1 0x5efb24a6ca25 in unicode_dealloc /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:1782:9
    #2 0x5efb24987e3f in _Py_Dealloc /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/object.c:3200:5
    #3 0x5efb249114d3 in Py_DECREF /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/refcount.h:418:9
    #4 0x5efb249114d3 in Py_XDECREF /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/refcount.h:511:9
    #5 0x5efb249114d3 in list_dealloc /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/listobject.c:561:13
    #6 0x5efb24987e3f in _Py_Dealloc /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/object.c:3200:5
    #7 0x735d1c93bc1f in Py_DECREF /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/refcount.h:418:9
    #8 0x735d1c93bc1f in _elementtree_XMLParser__setevents_impl /home/fuzz/WorkSpace/PyFuzz/cpython/./Modules/_elementtree.c:4217:13
    #9 0x735d1c93bc1f in _elementtree_XMLParser__setevents /home/fuzz/WorkSpace/PyFuzz/cpython/./Modules/clinic/_elementtree.c.h:1329:20
    #10 0x5efb2489c462 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_call.h:169:11
    #11 0x5efb2489c462 in PyObject_Vectorcall /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:327:12
    #12 0x5efb24b6a914 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/PyFuzz/cpython/Python/generated_cases.c.h:1620:35
    #13 0x5efb24b5afe4 in _PyEval_EvalFrame /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_ceval.h:121:16
    #14 0x5efb24b5afe4 in _PyEval_Vector /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:1990:12
    #15 0x5efb2489ad15 in _PyObject_VectorcallDictTstate /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:146:15
    #16 0x5efb2489cf7e in _PyObject_Call_Prepend /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:504:24
    #17 0x5efb249fbf90 in call_method /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:3076:19
    #18 0x5efb24a0d7ad in slot_tp_init /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:10828:21
    #19 0x5efb249e90d4 in type_call /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:2460:19
    #20 0x5efb2489b1c2 in _PyObject_MakeTpCall /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:242:18
    #21 0x5efb24b721ff in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/PyFuzz/cpython/Python/generated_cases.c.h:2920:35
    #22 0x5efb24b5a980 in _PyEval_EvalFrame /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_ceval.h:121:16
    #23 0x5efb24b5a980 in _PyEval_Vector /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:1990:12
    #24 0x5efb24b5a980 in PyEval_EvalCode /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:873:21
    #25 0x5efb24d15ca8 in run_eval_code_obj /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1365:12
    #26 0x5efb24d15ca8 in run_mod /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1459:19
    #27 0x5efb24d0fd3f in pyrun_file /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1293:15
    #28 0x5efb24d0fd3f in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:521:13
    #29 0x5efb24d0f335 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:81:15
    #30 0x5efb24d7f5a5 in pymain_run_file_obj /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:410:15
    #31 0x5efb24d7f5a5 in pymain_run_file /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:429:15
    #32 0x5efb24d7df5b in pymain_run_python /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:691:21
    #33 0x5efb24d7df5b in Py_RunMain /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:772:5
    #34 0x5efb24d7ea1d in pymain_main /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:802:12
    #35 0x5efb24d7eb83 in Py_BytesMain /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:826:12
    #36 0x735d1ed861c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #37 0x735d1ed8628a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #38 0x5efb246c40f4 in _start (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x1cd0f4) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5)

previously allocated by thread T0 here:
    #0 0x5efb24763f23 in malloc (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x26cf23) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5)
    #1 0x5efb24a3c108 in unicode_fill_utf8 /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:5904:19
    #2 0x5efb24a3c108 in unicode_ensure_utf8 /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:4225:19
    #3 0x5efb24a3c108 in PyUnicode_AsUTF8AndSize /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/unicodeobject.c:4243:9
    #4 0x735d1c93b2e7 in _elementtree_XMLParser__setevents_impl /home/fuzz/WorkSpace/PyFuzz/cpython/./Modules/_elementtree.c:4176:26
    #5 0x735d1c93b2e7 in _elementtree_XMLParser__setevents /home/fuzz/WorkSpace/PyFuzz/cpython/./Modules/clinic/_elementtree.c.h:1329:20
    #6 0x5efb2489c462 in _PyObject_VectorcallTstate /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_call.h:169:11
    #7 0x5efb2489c462 in PyObject_Vectorcall /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:327:12
    #8 0x5efb24b6a914 in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/PyFuzz/cpython/Python/generated_cases.c.h:1620:35
    #9 0x5efb24b5afe4 in _PyEval_EvalFrame /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_ceval.h:121:16
    #10 0x5efb24b5afe4 in _PyEval_Vector /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:1990:12
    #11 0x5efb2489ad15 in _PyObject_VectorcallDictTstate /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:146:15
    #12 0x5efb2489cf7e in _PyObject_Call_Prepend /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:504:24
    #13 0x5efb249fbf90 in call_method /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:3076:19
    #14 0x5efb24a0d7ad in slot_tp_init /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:10828:21
    #15 0x5efb249e90d4 in type_call /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/typeobject.c:2460:19
    #16 0x5efb2489b1c2 in _PyObject_MakeTpCall /home/fuzz/WorkSpace/PyFuzz/cpython/Objects/call.c:242:18
    #17 0x5efb24b721ff in _PyEval_EvalFrameDefault /home/fuzz/WorkSpace/PyFuzz/cpython/Python/generated_cases.c.h:2920:35
    #18 0x5efb24b5a980 in _PyEval_EvalFrame /home/fuzz/WorkSpace/PyFuzz/cpython/./Include/internal/pycore_ceval.h:121:16
    #19 0x5efb24b5a980 in _PyEval_Vector /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:1990:12
    #20 0x5efb24b5a980 in PyEval_EvalCode /home/fuzz/WorkSpace/PyFuzz/cpython/Python/ceval.c:873:21
    #21 0x5efb24d15ca8 in run_eval_code_obj /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1365:12
    #22 0x5efb24d15ca8 in run_mod /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1459:19
    #23 0x5efb24d0fd3f in pyrun_file /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:1293:15
    #24 0x5efb24d0fd3f in _PyRun_SimpleFileObject /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:521:13
    #25 0x5efb24d0f335 in _PyRun_AnyFileObject /home/fuzz/WorkSpace/PyFuzz/cpython/Python/pythonrun.c:81:15
    #26 0x5efb24d7f5a5 in pymain_run_file_obj /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:410:15
    #27 0x5efb24d7f5a5 in pymain_run_file /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:429:15
    #28 0x5efb24d7df5b in pymain_run_python /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:691:21
    #29 0x5efb24d7df5b in Py_RunMain /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:772:5
    #30 0x5efb24d7ea1d in pymain_main /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:802:12
    #31 0x5efb24d7eb83 in Py_BytesMain /home/fuzz/WorkSpace/PyFuzz/cpython/Modules/main.c:826:12
    #32 0x735d1ed861c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #33 0x735d1ed8628a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #34 0x5efb246c40f4 in _start (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x1cd0f4) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5)

SUMMARY: AddressSanitizer: heap-use-after-free (/home/fuzz/WorkSpace/PyFuzz/cpython/python+0x1e4fe6) (BuildId: 6eb748db4289186e9c2fb52e6d6b8534b12821c5) in strlen
Shadow bytes around the buggy address:
  0x502000005c00: fa fa fd fa fa fa fd fa fa fa fd fa fa fa fd fa
  0x502000005c80: fa fa fd fd fa fa fd fa fa fa fd fa fa fa fd fa
  0x502000005d00: fa fa fd fa fa fa fd fd fa fa fd fd fa fa fd fa
  0x502000005d80: fa fa fd fa fa fa fd fa fa fa fd fd fa fa fd fa
  0x502000005e00: fa fa fd fa fa fa 00 03 fa fa fd fd fa fa fd fa
=>0x502000005e80: fa fa fd fd fa fa 00 fa fa fa fd fd fa fa[fd]fa
  0x502000005f00: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000005f80: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000006000: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000006080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x502000006100: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==1106491==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-139211
* gh-139455
* gh-139456
* gh-139469
* gh-139470
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
