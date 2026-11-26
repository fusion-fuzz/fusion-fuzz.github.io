<?php
$im = imagecreatetruecolor(10, 10);
imagepolygon($im, [0, 0, 1, 1, 2, 2], 2147483647, 0);
