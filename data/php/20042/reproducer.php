<?php
set_error_handler(function ($fusion, $errstr) {
global $nan;
$nan = bin2hex(random_bytes(4));
});
settype($nan, 'object');
try {prev($nan);} catch (Exception $e) { echo($e); }
