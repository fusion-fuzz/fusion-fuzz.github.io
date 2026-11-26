<?php
$p = new Phar(__DIR__ . "/test.phar");
$p["index.php"] = "<?php echo 1;";
$big = str_repeat("a", 5 * 1024 * 1024);
$big2 = "x" . $big; // exceeds memory_limit; the OOM error is only raised at the next VM interrupt
$p->setStub("<?php __HALT_COMPILER(); ?>");
