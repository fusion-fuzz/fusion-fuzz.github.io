<?php
try {
class Test {
    public int $prop;
}
function define_const() {    $s = <<<'STR'
O:4:"Test":1:{s:4:"prop";O:8:"stdClass":1:{s:1:"y";R:2;}}
STR;
try {
    var_dump(unserialize($s));
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}
    $s = <<<'STR'
O:4:"Test":1:{s:4:"prop";a:1:{i:0;R:2;
STR;
var_dump(unserialize($s));
    test_defined();
    define("CUSTOM_CONSTANT", 1);
}
function test_defined() {
    var_dump(defined("CUSTOM_CONSTANT"));
    define_const();
    var_dump(defined("CUSTOM_CONSTANT"));
}
test_defined();
$s = <<<'STR'
O:4:"Test":1:{s:4:"prop";O:8:"stdClass":1:{s:1:"y";R:2;}}
STR;
try {
    var_dump(unserialize($s));
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}
$s = <<<'STR'
O:4:"Test":1:{s:4:"prop";a:1:{i:0;R:2;
STR;
var_dump(unserialize($s));
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
