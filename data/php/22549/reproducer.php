<?php
try {
$n = gmp_init(-5);
$fusion = $n;
$x = [0];
try {
$x **= 1;
} catch (Error $e) {
$x **= $fusion;
}
} catch (\Throwable $_ffl_e) {}
