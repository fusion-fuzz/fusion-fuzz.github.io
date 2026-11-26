<?php
try {
class foo {
public function &b() {
}
}
$foo = new foo;
$a = 'b';
try { zend_call_method_if_exists($foo,$a,$a); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
