<?php
$fname = __DIR__ . '/' . basename(__FILE__, '.php') . '.phar';
$pname = 'phar://' . $fname;
$b = new PharFileInfo($pname . '/a/subdir/here');
require_once 'files/phar_oo_test.inc';
$phar = new Phar($fname);
{
var_dump($ent->getATime());
}
