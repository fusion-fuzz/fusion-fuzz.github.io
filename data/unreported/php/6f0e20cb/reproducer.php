<?php
class C {
    public $self;
    function __construct() { $this->self = $this; }
    function __destruct() { throw new Exception("dtor"); }
}
function work($objs) {
    new C; // garbage cycle, its destructor throws when GC runs
    foreach (array_slice($objs, 0) as $obj) {
        // overwriting $obj adds the previous object to the GC root buffer
    }
}
$objs = [];
for ($i = 0; $i < 20000; $i++) {
    $objs[] = new stdClass;
}
try {
    work($objs);
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
