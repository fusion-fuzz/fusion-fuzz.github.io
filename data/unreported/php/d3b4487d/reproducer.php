<?php
$a = SplFixedArray::fromArray(["o", "o", "o"]);
try {
    for ($i = 0; $i < 4; $i++) {
        var_dump(strrchr("hello world", $a[$i]));
    }
} catch (Exception $e) {
    echo $e->getMessage(), "\n";
}
