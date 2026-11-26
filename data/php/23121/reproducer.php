<?php
try {
$sx1 = new SimpleXMLElement("<root />");
try { libxml_set_external_entity_loader($sx1); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
