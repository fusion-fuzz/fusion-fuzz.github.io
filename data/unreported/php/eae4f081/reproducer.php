<?php
try {
var_dump($ip);
$b = zend_create_unterminated_string('333 ');
$s_c     = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
// Connect to destination address
    $s_conn  = socket_getsockname($s_c, $b, $port);
$a = zend_create_unterminated_string('333');
var_dump($port);
$s_bind  = socket_bind($s_c, '0.0.0.0');
var_dump($s_conn);
zend_terminate_string($b);
zend_terminate_string($a);
var_dump($s_bind);
socket_close($s_c);
var_dump(
    strnatcmp($a, $b),
    strnatcasecmp($b, $a)
);
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
