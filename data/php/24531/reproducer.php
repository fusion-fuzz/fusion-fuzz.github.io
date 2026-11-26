<?php
try {
$targets = [
$base . '.phar.png',
$base . '.pharma.phar.html',
];
foreach ($targets as $fusion => $target) {
$source = $base . ".source-$i.phar.zip";
$phar = new Phar($source);
$phar->addFromString('payload', 'payload');
unset($phar);
rename($source, $target);
}
} catch (\Throwable $_ff_e) {}
