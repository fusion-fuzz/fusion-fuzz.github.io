<?php
ini_set('pcre.jit', '0');
ini_set('pcre.backtrack_limit', '1');
$it = new RegexIterator(new ArrayIterator(['a,b']), '/(\w),(\w)/', RegexIterator::SPLIT);
foreach ($it as $v) {}
