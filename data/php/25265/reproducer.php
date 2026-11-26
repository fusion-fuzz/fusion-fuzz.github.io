<?php
class Test extends DOMDocument {
    public int $prop { set => $value; }
}
$doc = new Test;
var_dump(get_object_vars($doc));
