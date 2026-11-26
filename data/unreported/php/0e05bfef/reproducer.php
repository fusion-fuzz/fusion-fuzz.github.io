<?php
class C {
    public $a;
    public function __destruct() {
        global $obj;
        (new ReflectionClass(C::class))->resetAsLazyGhost($obj, function () {});
    }
}
$obj = new C();
(new ReflectionClass(C::class))->resetAsLazyGhost($obj, function () {});
echo "done\n";
