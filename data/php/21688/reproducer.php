<?php
$dom = Dom\HTMLDocument::createEmpty();
$fusion = $dom;
echo $fusion->C14N() . PHP_EOL;
