// ---- preload.inc ----
<?php
function foo() {
    return new class extends Bar {};
}

// ---- test.php ----
<?php
enum Bar {}
var_dump(foo());
