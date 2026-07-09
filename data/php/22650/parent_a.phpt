<?php

$document = new DomDocument();
$root = $document->createElement('root');
$document->appendChild($root);
$root->setAttribute('attrib', 'value');
var_dump($root->attributes->length);
// Consistent with the method call
try {
    var_dump($root->attributes[-1]);
} catch (ValueError $e) {
    echo $e->getMessage(), "\n";
}
try {
    $root->attributes[][] = null;
} catch (Throwable $e) {
    echo $e->getMessage(), "\n";
}

?>