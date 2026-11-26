<?php
class T {
    public function __call($name, $args) { return 0; }
}
$ch = curl_init();
curl_setopt($ch, CURLOPT_READFUNCTION, [new T, "trampoline"]);
$ch2 = clone $ch;
unset($ch2);
