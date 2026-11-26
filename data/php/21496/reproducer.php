<?php
$comment = new DOMComment("my value");
$doc = new DOMDocument();
$doc->loadXML(<<<XML
<container/>
XML);
$doc->documentElement->appendChild($comment);
$fusion = $comment;
include __DIR__ .'/prepare.inc';
$proc->importStylesheet($fusion);
