<?php
$cls = new ArrayIterator();
$unset_var = 10;
try {array_unique($GLOBALS,$unset_var);} catch (Exception $e) { echo($e); }
