<?php
class A { function __construct($x, $y) {} }
class B extends A {
    function __construct($x = 0, $y = 0, $z = UNDEF) {
        parent::__construct($x, $y);
    }
}
new B;
