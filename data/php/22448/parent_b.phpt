<?php
$fiber = new Fiber(function (): int {
    $test = new _ZendTestFiber(function (): void {
        $value = Fiber::suspend(1);
        var_dump($value); // int(2)
        Fiber::suspend(3);
    });
    var_dump($test->start()); // NULL
    echo "unreachable\n"; // Test fiber throws.
    return 1;
});
$value = $fiber->start();
var_dump($value); // int(1)
$value = $fiber->resume(2 * $value);
var_dump($value); // int(3)
$value = $fiber->throw(new Exception('test'));

?>