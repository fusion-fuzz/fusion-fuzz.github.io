<?php
enum Foo: int {
case Bar = 0;
}
try {
$bar = Foo::Bar;
} catch (Error $e) {
}
$fusion = $bar;
array_walk($fusion, function($tk) {
});
var_dump(get_defined_vars());
