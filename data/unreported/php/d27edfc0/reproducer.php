<?php
$fname = __DIR__ . "/test.phar";
@unlink($fname);
$phar = new Phar($fname);
$phar["a.txt"] = "a";
$phar["b.txt"] = "b";
$fa = fopen("phar://$fname/a.txt", "r");
$fb = fopen("phar://$fname/b.txt", "r");
$phar->setMetadata("x"); // re-flushes the archive while both entries are open
fclose($fa);
fclose($fb);
