<?php
class W {
    public $context;
    function stream_open($path, $mode, $options, &$opened_path) { return true; }
}
class F extends php_user_filter {
    function filter($in, $out, &$consumed, bool $closing): int {
        if ($closing) {
            fopen("w2://x", "r");
        }
        return PSFS_PASS_ON;
    }
}
stream_wrapper_register("w2", "W");
stream_filter_register("f", "F");
stream_filter_append(STDOUT, "f");
