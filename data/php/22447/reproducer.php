<?php
try {
$dom1 = Dom\HTMLDocument::createEmpty();
$attribute1 = $dom1->createAttribute("my-attribute");
$container = $dom1->appendChild($dom1->createElement("container"));
$attribute2 = $dom1->createAttribute("my-attribute");
$attribute4 = $dom1->createAttributeNS("urn:a", "my-attribute");
$container->setAttributeNode($attribute1);
$container->setAttributeNode($attribute4);
var_dump($container->setAttributeNode($attribute2) === $attribute1);
var_dump($container->setAttributeNode($attribute1) === null);
} catch (\Throwable $_ffl_e) {}
