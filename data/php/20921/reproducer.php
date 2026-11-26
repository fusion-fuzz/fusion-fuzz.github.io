<?php
$cls = new SplTempFileObject();
$fusion = $cls;
var_dump($fusion->fseek(PHP_INT_MIN, SEEK_END));
