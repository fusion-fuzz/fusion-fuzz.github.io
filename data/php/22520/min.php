<?php
try {
$str = str_repeat('a', 1024 * 1024 * 1.25);
class C {
public $a;
}
$reflector = new ReflectionClass(C::class);
for ($i = 0; $i < 10000; $i++) {
$obj = $reflector->newLazyGhost(function ($obj) {});
$reflector->getProperty('a')->setRawValueWithoutLazyInitialization($obj, $obj);
}
} catch (\Throwable $_ffl_e) {}
