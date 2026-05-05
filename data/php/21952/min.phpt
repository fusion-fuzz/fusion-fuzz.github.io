--TEST--
Fused 3976c353 + 6d495787
--INI--
date.timezone=UTC
max_execution_time=2
opcache.enable=1
opcache.enable_cli=1
opcache.jit=1254
--FILE--
<?php
try {
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
$fusion = $doc;
$date = DateTime::createFromFormat(DateTime::COOKIE, "Mon, 21-Jan-2041 15:24:52 GMT");
print_r($fusion);
var_dump(get_defined_vars());
try { spl_object_id($notation); } catch (Exception $e) {};
try { spl_object_id($doc); } catch (Exception $e) {};
try { spl_object_id($date); } catch (Exception $e) {};
try { spl_object_id($notation); } catch (Exception $e) {};
try { spl_object_id($notation); } catch (Exception $e) {};
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
