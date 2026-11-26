<?php
try {
try { $cls = new mysqli(); } catch (\Throwable $_e) { $cls = new stdClass(); }
$path = $argv[1] ?? __FILE__;
if (is_file($path)) {
$code = file_get_contents($path);
if ($code !== false) {
eval('?>' . $code);
}
}
var_dump(get_defined_vars());
try { $cls->connect($fusion,$fusion,$fusion,$fusion,$fusion,$fusion); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
