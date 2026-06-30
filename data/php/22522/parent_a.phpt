<?php

function dump($dom, $name) {
    echo "\n=== $name ===\n";
    $list = $dom->getElementsByTagName($name)[0]->getInScopeNamespaces();
    foreach ($list as $entry) {
        echo "prefix: ";
        var_dump($entry->prefix);
        echo "namespaceURI: ";
        var_dump($entry->namespaceURI);
        echo "element->nodeName: ";
        var_dump($entry->element->nodeName);
        echo "---\n";
    }
}

$dom = Dom\XMLDocument::createFromString(<<<XML
<root xmlns="urn:a">
    <child xmlns="">
        <c:child xmlns:c="urn:c"/>
    </child>
    <b:sibling xmlns:b="urn:b" xmlns:d="urn:d" d:foo="bar">
        <d:child xmlns:d="urn:d2"/>
    </b:sibling>
</root>
XML);

dump($dom, 'c:child');
dump($dom, 'child');
dump($dom, 'b:sibling');
dump($dom, 'd:child');
dump($dom, 'root');

?>