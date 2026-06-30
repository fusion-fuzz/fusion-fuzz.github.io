<?php
var_dump((new ReflectionMethod('x', 'foo'))->getPrototype()->class);
var_dump((new ReflectionMethod('x', 'bar'))->getPrototype()->class);
?>
OK