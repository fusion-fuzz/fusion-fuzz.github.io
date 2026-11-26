<?php
try {
echo "\n-- Call array_slice() on array with string keys--\n";
echo "\n-- Call array_slice() on array with packed keys--\n";
try {
    strlen(null);
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
/*
 * Check that results of array_slice are correct when there are holes in buckets caused by unset()
 */
echo "*** Testing array_slice() : usage variations ***\n";
set_error_handler(function($_, $msg) {
    throw new Exception($msg);
});
echo "Done";
function dump_slice(array $input, $eToUnset, int $offset, int $length) {    /*
 * Check that results of array_slice are correct when there are holes in buckets caused by unset()
 */
echo "*** Testing array_slice() : usage variations ***\n";
    echo "\n-- Call array_slice() on array with string keys--\n";
    unset($input[$offsetToUnset]);
    var_dump(array_slice($input, $offset, $length));
}
$input = ['one' => 'un', 'two' => 'deux', 23 => 'twenty-three', 'zero'];
dump_slice($input, 'two', 0, 1);
dump_slice($input, 'two', 0, 2);
dump_slice($input, 'two', 0, 3);
dump_slice($input, 23, 1, 2);
$input = [10, 11, 12, 'thirteen'];
dump_slice($input, 0, 0, 1);
dump_slice($input, 1, 0, 1);
dump_slice($input, 1, 0, 3);
dump_slice($input, 1, -1, 1);
dump_slice($input, 1, 0, 3);
dump_slice($input, 1, -3, 3);
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
