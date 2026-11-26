<?php
class P {
    public int $d = 1;
    function &__get($name) {}
}
class C extends P {
    public int $d = 2 { get => parent::$d::get(); }
}
class GC extends C {
    public int $d { get => parent::$d::get(); }
}
var_dump((new GC)->d);
