<?php
try {
$gen = (function() {
    $x = new stdClass;
    try {
        yield from (function () {
            $x = new stdClass;
            try {
                print "Before suspend\n";
                Fiber::suspend();
                print "Not executed\n";
                yield;
            } finally {
                print "Finally (inner)\n";
            }
        })();
        print "Not executed\n";
        yield;
    } finally {
        print "Finally\n";
    }
})();
$fiber = new Fiber(function() use ($gen, &$fiber) {
    $gen->current();
    print "Not executed";
});
$fiber->start();
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
var_dump($value);
// int(1)
$value = $x->resume(2 * $value);
var_dump($value);
// int(3)
$value = $fiber->throw(new Exception('test'));
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}