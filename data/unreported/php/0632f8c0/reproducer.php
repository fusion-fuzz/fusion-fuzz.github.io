<?php
try {
set_error_handler(function() { throw new Exception; });
function test() {
    $x = str_replace(['foo'], [[]], ['foo']);
}
try {
    test();
} catch (Exception $e) {
    echo "caught\n";
}
$fusion = $x ?? [];
$agg_b_keys_e = is_array($e) ? array_key_first($e) : null;
$agg_b_type_n = gettype($fusion);
var_dump(gmp_popcount(-1));
var_dump(gmp_popcount(0));
var_dump(gmp_popcount(12123));
var_dump(gmp_popcount("52638927634234"));
var_dump(gmp_popcount("-23476123423433"));
$n = gmp_init("9876546789222");
var_dump(gmp_popcount($n));
try {
    var_dump(gmp_popcount(array()));
} catch (\TypeError $e) {
    echo $e->getMessage() . \PHP_EOL;
}
echo "Done\n";
var_dump(get_defined_vars());
try { gmp_fact($x); } catch (\Throwable $e) {};
try { gmp_fact($e); } catch (\Throwable $e) {};
try { gmp_fact($e); } catch (\Throwable $e) {};
try { gmp_fact($e); } catch (\Throwable $e) {};
try { gmp_fact($n); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
