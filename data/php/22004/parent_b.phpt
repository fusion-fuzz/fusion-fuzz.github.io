<?php
function foo() {
    $a = array(1,2,3);
    $b=&$a;
    $b=1;
    $a = new stdClass;
    $a->a=1;
    $a->b=2;
    $b=&$a;
}
foo();
echo "ok\n";
?>