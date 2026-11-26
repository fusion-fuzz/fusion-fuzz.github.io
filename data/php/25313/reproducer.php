<?php
set_error_handler(function($n, $s) { throw new Exception($s); });
function test($a, $b, $c, &$ref) {}
function gen($array) { foreach ($array as $e) yield $e; }
test(...gen([1, 2]), ...gen([3, 4]));
