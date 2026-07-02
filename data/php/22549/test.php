<?php
try {
var_dump(gmp_perfect_square(0));
var_dump(gmp_perfect_square("0"));
var_dump(gmp_perfect_square(-1));
var_dump(gmp_perfect_square(1));
var_dump(gmp_perfect_square(16));
var_dump(gmp_perfect_square(17));
var_dump(gmp_perfect_square("1000000"));
var_dump(gmp_perfect_square("1000001"));
$n = gmp_init(100101);
var_dump(gmp_perfect_square($n));
$n = gmp_init(64);
var_dump(gmp_perfect_square($n));
$n = gmp_init(-5);
var_dump(gmp_perfect_square($n));
try {
    var_dump(gmp_perfect_square(array()));
} catch (\TypeError $e) {
    echo $e->getMessage() . \PHP_EOL;
}
echo "Done\n";
$fusion = $n;
$x = [0];
try {
    $x **= 1;
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}
var_dump($x);
$x = [0];
try {
    $x **= $fusion;
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}
var_dump($x);
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}