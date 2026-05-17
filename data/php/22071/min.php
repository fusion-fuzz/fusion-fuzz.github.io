<?php
declare(strict_types=1);
try {
$nan = NAN;
$inf = INF;
$ninf = -INF;
$values = [0, 1, -1, PHP_INT_MAX, PHP_INT_MIN, 1.0, 1.5, $nan, $inf, $ninf, "0", "1", "-1", "1e309", "foo", "", null, true, false, [], [1, 2], ["a" => 1], " 42 ", "042", "0x10"];
foreach ($values as $v) {
    is_nan(is_float($v) ? $v : (float)$v);
    is_finite(is_float($v) ? $v : (float)$v);
    gettype($v);
    settype($v, 'string');
    settype($v, 'array');
    settype($v, 'object');
}
$a = ["x" => 1, "y" => [2, 3], "z" => ["k" => "v"]];
$b = $a;
$b["y"][1] = 99;
$b["z"]["k"] = "w";
$c = $a;
$c[] = 4;
unset($c["x"]);
$e = enum_exists('UnitEnum') ? UnitEnum::cases() : [];
$map = [];
foreach ($e as $case) {
    $map[$case->name] = $case->name;
}
$nested = ["a" => ["b" => ["c" => 1]]];
$ref = &$nested["a"]["b"];
$ref["d"] = 2;
$s = "abc";
for ($i = 0; $i < 3; $i++) {
    $s .= $i;
    $s = substr($s, 0, strlen($s));
}
$x = 0;
while ($x < 5) {
    if ($x === 2) {
        $x++;
        continue;
    }
    if ($x === 4) {
        break;
    }
    $x++;
}
try {
    throw new ArgumentException("value");
} catch (Throwable $t) {
}
echo "";
function foo() {
    $a = array();  // [rc1, array]
    $a = 1;        // [rc1, long, reg]
    $x = $a;
    var_dump($x);
}
foo();
var_dump(get_defined_vars());
try { imagearc($fusion,$x,$fusion,$fusion,$fusion,$x,$a,$fusion); } catch (\Throwable $e) {};
try { imagearc($x,$a,$a,$a,$x,$fusion,$fusion,$x); } catch (\Throwable $e) {};
try { imagearc($a,$fusion,$a,$a,$fusion,$x,$x,$fusion); } catch (\Throwable $e) {};
try { imagearc($fusion,$x,$x,$a,$fusion,$fusion,$a,$fusion); } catch (\Throwable $e) {};
try { imagearc($x,$fusion,$fusion,$a,$fusion,$fusion,$a,$x); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}