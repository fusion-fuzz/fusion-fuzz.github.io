<?php
set_error_handler(function() { throw new Exception; });
class bar  {
static public function __callstatic($fusion, $b) {
}
public function test() {
call_user_func('self::y');
}
}
$x = new bar;
$x->test();
