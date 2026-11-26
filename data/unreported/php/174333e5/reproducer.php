<?php
class C {
    #[\Deprecated]
    public function __call($name, $args) {}
}
set_error_handler(function ($errno, $errstr) {
    throw new Exception($errstr);
});
try {
    (new C)->foo();
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
