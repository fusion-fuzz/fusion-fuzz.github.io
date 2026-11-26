<?php
class P {
    public $prop { get => 1; }
}
interface I {
    public $prop { get; set; }
}
class C extends P implements I {}
echo "done\n";
