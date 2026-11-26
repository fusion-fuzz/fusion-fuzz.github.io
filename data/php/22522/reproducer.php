<?php
try {
function dump($dom, $name) {
$list = $dom->getElementsByTagName($name)[0]->getInScopeNamespaces();
foreach ($list as $entry) {
$dom = Dom\XMLDocument::createFromString(<<<XML
<root xmlns="urn:a">
<child xmlns="">
<c:child xmlns:c="urn:c"/>
</child>
<b:sibling xmlns:b="urn:b" xmlns:d="urn:d" d:foo="bar">
</b:sibling>
</root>
XML);
dump($dom, 'c:child');
dump($dom, 'child');
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
} catch (\Throwable $_ffl_e) {}
