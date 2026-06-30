<?php

function main() {
    $code = '(function() {' . PHP_EOL;
    for ($i = 0; $i < 10000; $i++) {
        $code .= '  return function() {' . PHP_EOL;
    }
    try {
        eval($code);
    } catch (ParseError $e) {
        echo 'ParseError: ', $e->getMessage(), PHP_EOL;
    }
}

main();