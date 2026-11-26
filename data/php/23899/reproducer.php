<?php
try {
try {
$file = $dirname . '__tmp_oo_cancel_incorrect_return.zip';
$zip = new ZipArchive;
if (!$zip->open($file, ZIPARCHIVE::CREATE)) {
}
} catch (\Throwable $_ffl_e) {}
var_dump($zip->registerCancelCallback(function () {
return [];
}));
var_dump($zip->addFromString(PHP_BINARY, 'entry #1'));
} catch (\Throwable $_ffl_e) {}
