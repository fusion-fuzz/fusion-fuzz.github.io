<?php
try {
$exp = imagecreate(100, 100);
imageresolution($exp, 71, 0x80000000);
imagepng($exp, $filename);
} catch (\Throwable $_ffl_e) {}
