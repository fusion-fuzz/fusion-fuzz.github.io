<?php
try {
function main() {
    $code = '(function() {' . PHP_EOL;
    for ($i = 0; $i < 10000; $i++) {
        $code .= '  return function() {' . PHP_EOL;
    }
    try {
        eval($code);
    } catch (ParseError $e) {
    main();
        echo 'ParseError: ', $e->getMessage(), PHP_EOL;
    }
}
main();
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}