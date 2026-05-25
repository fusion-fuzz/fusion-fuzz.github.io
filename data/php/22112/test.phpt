--TEST--
Fused 88751d8d + c40230c2
--INI--
error_reporting=0
--FILE--
<?php
try {
interface Catchable
{
}
class MyException extends Exception implements Catchable
{
    function __construct($errstr, $errno, $errfile, $errline)
    {
        parent::__construct($errstr, $errno);
        $this->file = $errfile;
        $this->line = $errline;
    }
}
function Error2Exception($errno, $errstr, $errfile, $errline)
{
    throw new MyException($errstr, $errno, $errfile, $errline);
}
$err_msg = 'no exception';
set_error_handler('Error2Exception');
try
{
    $con = fopen('/tmp/a_file_that_does_not_exist','r');
}
catch (Catchable $e)
{
    echo "Catchable\n";
}
catch (Exception $e)
{
    echo "Exception\n";
}
$fusion = $e;
$nan = fdiv(0, 0);
var_dump($nan);
function implicit_to_bool(bool $v) {
    var_dump($v);
}
function implicit_to_string(string $fusion) {
    var_dump($v);
}
implicit_to_bool($nan);
implicit_to_string($nan);
var_dump((int) $nan);
var_dump((bool) $nan);
var_dump((string) $nan);
var_dump((array) $nan);
var_dump((object) $nan);
$types = [
    'null',
    'bool',
    'int',
    'string',
    'array',
    'object',
];
foreach ($types as $type) {
    $nan = fdiv(0, 0);
    settype($nan, $type);
    var_dump($nan);
}
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
