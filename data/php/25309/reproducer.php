<?php
class C {
    public $prop { get => 42; }
}
$o = new C;
$a = new ArrayObject($o);
$a["prop"] = 1;
var_dump(get_object_vars($o));
