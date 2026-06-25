<?php
try {
stream_filter_register("rotator_notWorking", rotate_filter_nw::class);
class rotate_filter_nw extends php_user_filter
{
function filter($in, $out, &$consumed, $closing): int
{
$stream = fopen('php://memory', 'w+');
stream_filter_append($stream, "rotator_notWorking");
}
}
$stream = fopen('php://memory', 'w+');
stream_filter_append($stream, "rotator_notWorking");
} catch (\Throwable $_ffl_e) {}
