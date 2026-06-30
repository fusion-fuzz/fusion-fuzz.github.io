<?php

class C {
    public $a;
}

$reflector = new ReflectionClass(C::class);

for ($i = 0; $i < 10000; $i++) {
    $obj = $reflector->newLazyGhost(function ($obj) {});

    // Add to roots
    $obj2 = $obj;
    unset($obj2);

    // Initialize all props to mark object non-lazy. Also create a cycle.
    $reflector->getProperty('a')->setRawValueWithoutLazyInitialization($obj, $obj);
}

var_dump($obj);

?>