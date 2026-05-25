<?php
try {
function Error2Exception($errno, $errstr, $errfile, $errline)
{
throw new MyException($errstr, $errno, $errfile, $errline);
}
set_error_handler('Error2Exception');
$nan = fdiv(0, 0);
function implicit_to_bool(bool $v) {
}
implicit_to_bool($nan);
} catch (\Throwable $_ffl_e) {}
