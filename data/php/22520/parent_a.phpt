<?php
$str = str_repeat('a', 1024 * 1024 * 1.25);
class DestructableObject
{
    public function __destruct()
    {
        DestructableObject::__destruct();
    }
}
$_ = new DestructableObject();
?>