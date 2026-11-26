<?php
$dom = Dom\XMLDocument::createFromString('<!DOCTYPE root [<!NOTATION GIF SYSTEM "image/gif">]><root/>');
$notation = $dom->doctype->notations->getNamedItem("GIF");
var_dump(clone $notation);
