<?php
$num = new BcMath\Number(1);
$a = [1];
$a[] =& $num->b;
$a[] =& $a;
var_dump($a);
