# Memory leak in function `my_ElementDeclHandler` of `pyexpat`

**Issue:** [https://github.com/python/cpython/issues/140593](https://github.com/python/cpython/issues/140593) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-25T15:45:21Z`

**Labels:** `type-bug`, `extension-modules`, `topic-XML`

## Description

# Bug report

### Bug description:

```python
import unittest
from xml.parsers import expat
class SetAttributeTest(unittest.TestCase):
    def setUp(self):
        self.parser = expat.ParserCreate(namespace_separator='!')
data = b'<?xml version="1.0" encoding="iso-8859-1" standalone="no"?>\n<?xml-stylesheet href="stylesheet.css"?>\n<!-- comment data -->\n<!DOCTYPE quotations SYSTEM "quotations.dtd" [\n<!ELEMENT root ANY>\n<!ATTLIST root attr1 CDATA #REQUIRED attr2 CDATA #IMPLIED>\n<!NOTATION notation SYSTEM "notation.jpeg">\n<!ENTITY acirc "&#226;">\n<!ENTITY external_entity SYSTEM "entity.file">\n<!ENTITY unparsed_entity SYSTEM "entity.file" NDATA notation>\n%unparsed_entity;\n]>\n\n<root attr1="value1" attr2="value2&#8000;">\n<myns:subelement xmlns:myns="http://www.python.org/namespace">\n     Contents of subelements\n</myns:subelement>\n<sub2><![CDATA[contents of CDATA section]]></sub2>\n&external_entity;\n&skipped_entity;\n\xb5\n</root>\n'
class ParseTest(unittest.TestCase):
    class Outputter:
        def __init__(self):
            self.out = []
        def NotStandaloneHandler(self):
            return 3.1415926535897932384626
        def ExternalEntityRefHandler(self, *args):
            return 1
        def XmlDeclHandler(self, *args):
            return 1
        def ElementDeclHandler(self, *args):
            return 1
    handler_names = ['NotStandaloneHandler', 'ExternalEntityRefHandler', 'XmlDeclHandler', 'ElementDeclHandler']
    def _hookup_callbacks(self, parser, handler):
        for name in self.handler_names:
            setattr(parser, name, getattr(handler, name))
    def test_parse_str(self):
        out = self.Outputter()
        parser = expat.ParserCreate(namespace_separator='!')
        self._hookup_callbacks(parser, out)
        parser.Parse(data.decode('iso-8859-1'), True)
if __name__ == '__main__':
    unittest.main()
```

```
=================================================================
==589201==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 32 byte(s) in 1 object(s) allocated from:
    #0 0x7223099539c7 in malloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:69
    #1 0x7223061c79e7 in doProlog ../Modules/expat/xmlparse.c:6096
    #2 0x7223061d178e in prologProcessor ../Modules/expat/xmlparse.c:5183
    #3 0x7223061d178e in prologInitProcessor ../Modules/expat/xmlparse.c:4985
    #4 0x7223061d178e in prologInitProcessor ../Modules/expat/xmlparse.c:4979
    #5 0x7223061a176e in callProcessor ../Modules/expat/xmlparse.c:1291
    #6 0x7223061b4603 in PyExpat_XML_ParseBuffer ../Modules/expat/xmlparse.c:2489
    #7 0x72230619d523 in pyexpat_xmlparser_Parse_impl ../Modules/pyexpat.c:885
    #8 0x72230619d523 in pyexpat_xmlparser_Parse ../Modules/clinic/pyexpat.c.h:109
    #9 0x63399a5acee7 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #10 0x63399a5acee7 in PyObject_Vectorcall ../Objects/call.c:327
    #11 0x63399a44ead2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #12 0x63399a931b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #13 0x63399a931b55 in _PyEval_Vector ../Python/ceval.c:2001
    #14 0x63399a5b6d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #15 0x63399a5b6d90 in method_vectorcall ../Objects/classobject.c:95
    #16 0x63399a5b1ffe in _PyVectorcall_Call ../Objects/call.c:273
    #17 0x63399a5b1ffe in _PyObject_Call ../Objects/call.c:348
    #18 0x63399a5b1ffe in PyObject_Call ../Objects/call.c:373
    #19 0x63399a451eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #20 0x63399a931b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #21 0x63399a931b55 in _PyEval_Vector ../Python/ceval.c:2001
    #22 0x63399a5b0623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #23 0x63399a5b0cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #24 0x63399a771444 in call_method ../Objects/typeobject.c:3077
    #25 0x63399a771444 in slot_tp_call ../Objects/typeobject.c:10606
    #26 0x63399a5ab4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #27 0x63399a44f7ac in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:4021
    #28 0x63399a931b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #29 0x63399a931b55 in _PyEval_Vector ../Python/ceval.c:2001
    #30 0x63399a5b6d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #31 0x63399a5b6d90 in method_vectorcall ../Objects/classobject.c:95
    #32 0x63399a5b1ffe in _PyVectorcall_Call ../Objects/call.c:273
    #33 0x63399a5b1ffe in _PyObject_Call ../Objects/call.c:348
    #34 0x63399a5b1ffe in PyObject_Call ../Objects/call.c:373
    #35 0x63399a451eb7 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:2616
    #36 0x63399a931b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #37 0x63399a931b55 in _PyEval_Vector ../Python/ceval.c:2001
    #38 0x63399a5b0623 in _PyObject_VectorcallDictTstate ../Objects/call.c:135
    #39 0x63399a5b0cdc in _PyObject_Call_Prepend ../Objects/call.c:504
    #40 0x63399a771444 in call_method ../Objects/typeobject.c:3077
    #41 0x63399a771444 in slot_tp_call ../Objects/typeobject.c:10606
    #42 0x63399a5ab4cd in _PyObject_MakeTpCall ../Objects/call.c:242
    #43 0x63399a44ead2 in _PyEval_EvalFrameDefault ../Python/generated_cases.c.h:1620
    #44 0x63399a931b55 in _PyEval_EvalFrame ../Include/internal/pycore_ceval.h:121
    #45 0x63399a931b55 in _PyEval_Vector ../Python/ceval.c:2001
    #46 0x63399a5b6d90 in _PyObject_VectorcallTstate ../Include/internal/pycore_call.h:169
    #47 0x63399a5b6d90 in method_vectorcall ../Objects/classobject.c:95

SUMMARY: AddressSanitizer: 32 byte(s) leaked in 1 allocation(s).
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

<!-- gh-linked-prs -->
### Linked PRs
* gh-140602
* gh-140624
* gh-140625
* gh-140629
* gh-140630
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
