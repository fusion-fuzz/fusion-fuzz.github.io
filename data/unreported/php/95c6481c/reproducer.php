<?php
class D {
    function __destruct() { throw new Exception("dtor"); }
}
function f() {
    $d = new D;
}
try {
    f(new stdClass); // extra argument
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
