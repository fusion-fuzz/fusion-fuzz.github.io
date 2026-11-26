<?php
const VALUE = true;
class MyIterator extends ArrayIterator {
    public $var = VALUE;
}
$ao = new ArrayObject(["a" => 1], 0, "MyIterator");
foreach ($ao as $v) {}
