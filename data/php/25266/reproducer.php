<?php
$rp = new ReflectionProperty(DOMDocument::class, "nodeName");
var_dump($rp->isReadable(null, new DOMDocument));
