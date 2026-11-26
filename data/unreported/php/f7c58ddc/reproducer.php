<?php
$p = new Phar(__DIR__ . "/test.phar");
$p["a"] = "a";
$r = get_resources("stream");
fclose(end($r));
$p["b"] = "b";
