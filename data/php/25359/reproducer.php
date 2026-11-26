<?php
namespace test;
try { throw new \Exception; } catch (\Exception $e) {}
function f(&$a = null, &$b = null) {}
function g($s) {
	f(b: $s);
	return $s;
}
g("x");
var_dump(strtolower(g("FALSE")));
