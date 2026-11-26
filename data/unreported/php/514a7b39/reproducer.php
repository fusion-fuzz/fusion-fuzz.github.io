<?php
set_error_handler(function() { throw new Exception(); });
function f(array $input) {
    unset($input[$undef]);
}
$input = ["a" => 1];
f($input);
