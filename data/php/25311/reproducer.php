<?php
$s = str_repeat("a", 5 * 1024 * 1024);
$s .= $s;
array_map(fn($x) => $x, [1]);
