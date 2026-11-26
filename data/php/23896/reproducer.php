<?php
set_error_handler(function($severity, $m) { throw new Exception($m, $severity); });
class P {}
class C extends P {
public function u(string $s) { return unserialize($s); }
}
try { (new C)->u('O:3:"FOO":0:{}'); } catch (Throwable $e) {}
