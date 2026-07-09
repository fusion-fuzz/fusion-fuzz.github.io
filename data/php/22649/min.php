<?php
try {
$zip = new ZipArchive;
$file = $dirname . 'oo_setcomment.zip';
if (!$zip->open($file, ZIPARCHIVE::CREATE)) {
}
$zip->addFromString('dir/entry2d.txt', 'entry #2');
var_dump($zip->setCommentName('dir/entry2d.txt', 'dir/entry2d.txt'));
} catch (\Throwable $_ffl_e) {}
