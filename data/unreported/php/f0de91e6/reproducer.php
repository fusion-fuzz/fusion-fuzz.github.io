<?php
try {
interface I {
    public function foo(): float;
}
class Base implements I {
    public function foo(): float {
        $start = microtime(true);
        debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 10);
        return microtime(true) - $start;
    }
}
class Wrap implements I {
    private I $inner;
    private int $data;
    
    public function __construct(I $inner, int $data) {
        $this->inner = $inner;
        $this->data = $data;
    }
    
    public function foo(): float {
        return $this->inner->foo();
    }
}
function best(callable $func): float {
    $min = $func();
    for ($i = 0; $i < 9; $i++) {
        $min = min($min, $func());
    }
    return $min;
}
function main() {
    $i = new Base();
    for ($x = 0; $x < 1000; $x++) {
        $i = new Wrap($i, $x);
    }
    $short = best([$i, 'foo']);
    for ($x = 0; $x < 9000; $x++) {
        $i = new Wrap($i, $x);
    }
    $long = best([$i, 'foo']);
    
    $ratio = $long / $short;
    
    $allowed = 5.0;
    if ($ratio >= $allowed) {
        echo "short: $short\nlong: $long\nratio: $ratio\nallowed: $allowed\n";
    }
}
main();
class Foo { 
    public static function method() { 
        return static::class;
    }
}
class Bar extends Foo {}
$bar = Bar::method(...);
echo $bar();
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
