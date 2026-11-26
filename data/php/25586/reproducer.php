<?php
class W {
    public $context;
    function stream_open($path, $mode, $options, &$opened_path) { return true; }
    function stream_flush() { global $s; fclose($s); return true; }
}
stream_wrapper_register("bomb", "W");
$s = fopen("bomb://", "w");
proc_open("true", [1 => $s], $pipes);
