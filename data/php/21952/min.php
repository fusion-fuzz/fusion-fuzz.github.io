<?php
try {
$doc = new DOMDocument;
$doc->loadXML(<<<'XML'
<!DOCTYPE books [
<!NOTATION myNotation SYSTEM "test.dtd">
]>
<container/>
XML);
$notation = $doc->doctype->notations[0];
$doc->removeChild($doc->doctype);
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}