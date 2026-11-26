<?php
function f(int $n) {
    if ($n > 0) {
        f($n - 1);
        return;
    }
    throw new Exception();
}
try {
    f(10000);
} catch (Exception $e) {
}
var_dump(1);
