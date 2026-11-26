<?php
try {
// NULL
class Test {
    public int $x;
}
$test = new Test;
$test->x = 42;
try {
    settype($test->x, 'array');
} catch (TypeError $e) {
    echo $e->getMessage(), "\n";
}
// Same as $test->x = (string) $test->x.
// Leaves value unchanged due to coercion
var_dump($test->x);
var_dump($test->x);
settype($test->x, 'string');
$test = new _ZendTestFiber(function (): void {
    $fiber = new Fiber(function (): void {
        var_dump(_ZendTestFiber::suspend(10)); // string(2) "10"
        Fiber::suspend(20);
        echo "unreachable\n"; // Fiber is not resumed.
    });
    var_dump($fiber->start()); // int(20)
});
$fiber = new Fiber(function (): void {
    var_dump(Fiber::suspend(1)); // string(1) "1"
    var_dump(Fiber::suspend(2)); // string(1) "2"
});
var_dump($test->start());
// int(10)
var_dump($test->start());
// int(1)
var_dump($fiber->resume('1'));
// int(2)
var_dump($test->resume('10'));
// NULL
var_dump($fiber->resume('2'));
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
