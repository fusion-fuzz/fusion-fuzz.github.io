<?php
class Test extends ArrayObject {
    public function offsetExists($key): bool {
        $GLOBALS["obj"] = null;
        return true;
    }
}
$obj = new Test;
var_dump(empty($obj["foo"]));
