<?php
class C {
    public $prop = 'x' {
        set => $value;
    }
}
$c = new C;
$ao = new ArrayObject($c);
unset($ao['prop']);
var_dump($c->prop);
