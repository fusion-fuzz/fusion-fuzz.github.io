<?php
$im = imagecreatetruecolor(10, 10);
// Tuffy.ttf from ext/gd/tests
imagettftext($im, 10, NAN, 0, 5, 0, __DIR__ . "/Tuffy.ttf", "a");
