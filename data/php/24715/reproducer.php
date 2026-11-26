<?php
function test(string $name, object $obj) {
$serialized = serialize($obj);
}
class C_ff {
public $a;
}
class D {
public function __construct() {
$this->self = $this;
}
public function __destruct() {
global $obj, $reflector;
$reflector->resetAsLazyGhost($obj, function () {});
}
}
try {
new D();
$reflector = new ReflectionClass(C_ff::class);
$obj = $reflector->newLazyGhost(new class {
function __invoke () {}
function __destruct() {
gc_collect_cycles();
}
});
test('Proxy', $obj);
} catch (\Throwable $_ff_e) {}
