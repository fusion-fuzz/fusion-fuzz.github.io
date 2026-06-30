--TEST--
Fused f0d0f870 + 076dcb2d (stmt_ba)
--INI--
opcache.enable=1
opcache.enable_cli=1
opcache.file_update_protection=0
opcache.protect_memory=1
;opcache.jit_debug=257
serialize_precision=-1
opcache.enable=1
opcache.enable_cli=1
opcache.jit=1254
--FILE--
<?php
try {
function foo() {
    $x = 1;
    var_dump(++$x); // reg -> mem, mem
    var_dump($x);
    foo();}
$dom = Dom\XMLDocument::createFromString(<<<XML
<?xml version="1.0"?>
<html>
    <body xmlns="http://www.w3.org/1999/xhtml">
        <h1>hello world.</h1>
        <p>test</p>
        <br/>
        <p>test 2</p>
        <default:p xmlns:default="http://www.w3.org/1999/xhtml" class="foo" id="import">namespace prefixed</default:p>
    </body>
</html>
XML);
// Note the HTMLDocument class!
$dom2 = Dom\HTMLDocument::createEmpty();
$imported = $dom2->importNode($dom->documentElement, true);
$dom2->appendChild($imported);
$x = $dom2->getElementsByTagName("body")[0];
$default_p = $body->lastElementChild;
var_dump($default_p->prefix);
var_dump($default_p->namespaceURI);
echo $dom2->saveXml();
foo();
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
