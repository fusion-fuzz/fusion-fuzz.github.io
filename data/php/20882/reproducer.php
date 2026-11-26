<?php
class MyIterator extends RecursiveDirectoryIterator {
}
$workdir = __DIR__.'/getMTime_errors';
for ($i = 0; $i < 4; $i++) {
try {
$phar = new \Phar($workdir . "/test$i.phar");
$phar->buildFromIterator(
new RecursiveIteratorIterator(
new MyIterator($workdir . '/content', FilesystemIterator::SKIP_DOTS)
),
$fusion
);
} catch (Throwable $e) {
}
}
