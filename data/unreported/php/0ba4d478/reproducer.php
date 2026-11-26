<?php
set_error_handler(function ($errno, $errstr) {
    throw new Exception($errstr);
});
function test() {
    $f = function (&$ref) {};
    call_user_func($f, ref: null);
}
test();
