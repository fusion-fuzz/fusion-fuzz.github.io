<?php
function foo($i) {
static $a = $i <= PHP_FLOAT_MAX ? foo($i + 1) : "Done $i";
}
foo(0);
