<?php
$zip = new ZipArchive();
$zip->open(__DIR__ . "/test.zip", ZipArchive::CREATE | ZipArchive::OVERWRITE);
file_put_contents(__DIR__ . "/test.txt", "contents");
$zip->addFile(__DIR__ . "/test.txt", "file.txt");
unlink(__DIR__ . "/test.txt");
set_error_handler(function () { throw new Exception; });
