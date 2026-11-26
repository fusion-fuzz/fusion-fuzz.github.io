<?php
$dom = Dom\XMLDocument::createFromString("<root/>");
$pad = str_repeat("a", 1400000);
$dom->documentElement->closest("root");
