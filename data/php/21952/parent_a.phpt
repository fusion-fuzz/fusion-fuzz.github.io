<?php
$doc = new DOMDocument;
$doc->loadXML(<<<'XML'
<?xml version="1.0"?>
<!DOCTYPE books [
<!NOTATION myNotation SYSTEM "test.dtd">
]>
<container/>
XML);
$notation = $doc->doctype->notations[0];
var_dump($notation->nodeName, $notation->publicId, $notation->systemId);
$doc->removeChild($doc->doctype);
var_dump($notation->nodeName, $notation->publicId, $notation->systemId);
unset($doc);
var_dump($notation->nodeName, $notation->publicId, $notation->systemId);
?>