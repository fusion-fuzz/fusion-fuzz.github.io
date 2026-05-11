<?php
$filename = __DIR__ . DIRECTORY_SEPARATOR . 'imageresolution_png.png';

$exp = imagecreate(100, 100);
imagecolorallocate($exp, 255, 0, 0);

imageresolution($exp, 71);
imagepng($exp, $filename);
$act = imagecreatefrompng($filename);
var_dump(imageresolution($act));

imageresolution($exp, 71, 299);
imagepng($exp, $filename);
$act = imagecreatefrompng($filename);
var_dump(imageresolution($act));
?>