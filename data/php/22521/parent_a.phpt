<?php

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

$body = $dom2->getElementsByTagName("body")[0];
$default_p = $body->lastElementChild;
var_dump($default_p->prefix);
var_dump($default_p->namespaceURI);

echo $dom2->saveXml();

?>