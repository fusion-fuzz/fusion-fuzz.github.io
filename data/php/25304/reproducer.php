<?php
$o = new stdClass;
ob_start(function ($buffer) use (&$storage) {
    $storage .= $buffer;
    return '';
}, 1);
while ($o < 10);
