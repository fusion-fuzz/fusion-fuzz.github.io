<?php
function foo() {
    $a = array();  // [rc1, array]
    $a = 1;        // [rc1, long, reg]
    $x = $a;
    var_dump($x);
}
foo();
?>