<?php
$doc = new DOMDocument;
$doc->loadXML(<<<'XML'
<!DOCTYPE books [
<!NOTATION myNotation SYSTEM "test.dtd">
]>
<container/>
XML);
$notation = $doc->doctype->notations[0];  // PHP wrapper acquired
$doc->removeChild($doc->doctype);         // underlying xmlNotation freed here
var_dump(get_defined_vars());             // UAF triggered via $notation
