--TEST--
Fused 9f5b5b13 + 5d119c76 (stmt_ba)
--INI--
serialize_precision=75
--FILE--
<?php
try {
function dump($dom, $name) {
    echo "\n=== $name ===\n";
    $list = $dom->getElementsByTagName($name)[0]->getInScopeNamespaces();
    foreach ($list as $entry) {
        echo "prefix: ";
        var_dump($entry->prefix);
        echo "namespaceURI: ";
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
var_dump(get_defined_vars());
try { ini_restore($dom); } catch (\Throwable $e) {};
try { ini_restore($dom); } catch (\Throwable $e) {};
try { ini_restore($name); } catch (\Throwable $e) {};
try { ini_restore($entry); } catch (\Throwable $e) {};
try { ini_restore($fusion); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
