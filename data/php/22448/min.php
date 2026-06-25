<?php
try {
$fiber = new Fiber(function() use ($gen, &$fiber) {
});
$fiber = new Fiber(function (): int {
$test = new _ZendTestFiber(function (): void {
$value = Fiber::suspend(1);
});
var_dump($test->start()); // NULL
});
$value = $fiber->start();
} catch (\Throwable $_ffl_e) {}
