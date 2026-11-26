<?php
$dom = Dom\XMLDocument::createFromString(<<<XML
<root>
    <a:root1 xmlns:a="urn:a">
        <a:child xmlns:b="urn:b">
            <b:child1 xmlns:a="urn:x">bar</b:child1>
        </a:child>
    </a:root1>
</root>
XML);
$attr = $dom->documentElement->firstElementChild->attributes[0];
$attr->rename("urn:x", "a:foo");
echo $dom->saveXML();
