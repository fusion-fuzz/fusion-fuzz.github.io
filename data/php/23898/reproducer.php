<?php
class rotate_filter_nw extends php_user_filter
{
public function filter($in, $out, &$consumed, $closing): int
{
$stream = fopen('php://memory', 'w+');
stream_filter_register("\0", rotate_filter_nw::class);
stream_filter_append($stream, "rotator_notWorking");
}
}
try {
try {
stream_filter_register("rotator_notWorking", rotate_filter_nw::class);
$stream = fopen('php://memory', 'w+');
stream_filter_append($stream, "rotator_notWorking");
} catch (\Throwable $_ffl_e) {}
} catch (\Throwable $_ffl_e) {}
