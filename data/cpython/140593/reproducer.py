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
