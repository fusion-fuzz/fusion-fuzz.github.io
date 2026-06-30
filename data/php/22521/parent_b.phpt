<?php
function foo() {
    $x = 1;
    var_dump(++$x); // reg -> mem, mem
    var_dump($x);
}
foo();
?>