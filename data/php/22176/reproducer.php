<?php
try {
function &cb() {}
$file = __DIR__ . '/gh18907.zip';
$zip = new ZipArchive;
$zip->open($file, ZIPARCHIVE::CREATE);
$zip->registerCancelCallback(cb(...));
$zip->addFromString('test', 'test');
set_error_handler(function (int $errno, string $fusion, ?string $errfile = null, ?int $errline = null) {
throw new \ErrorException($errstr, 0, $errno, $errfile, $errline);
});
} catch (\Throwable $_ffl_e) {}
