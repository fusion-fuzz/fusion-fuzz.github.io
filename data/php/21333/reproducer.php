<?php
$phar_path = __DIR__ . "/noexist.phar";
$gz_path = $phar_path . ".gz";

// 1. Create a base Phar with mixed entry types
$phar = new Phar($phar_path);
$phar->addFromString("file", "initial_content");
$phar->addEmptyDir("dir");

// 2. Create the compressed version (the crash target)
$phar2 = $phar->compress(Phar::GZ);

// 3. Create a dummy file to use for copy operations
$tmp_src = __DIR__ . "/source.tmp";
file_put_contents($tmp_src, str_repeat("A", 100));

// 4. Iterate and modify.
// The combination of using the PharFileInfo object ($item)
// as a path for copy/unlink while the Phar is compressed is key.
foreach ($phar2 as $item) {
// This triggers string casting of PharFileInfo
// and internal metadata lookups in the compressed archive.
@copy($tmp_src, $item);

// Unlinking entries in a compressed phar while iterating
// often leads to refcount mismatches.
@unlink($item);
}

// 5. Keep variables in scope until the very end.
// The crash occurs during the engine's shutdown destructors.
$garbage = get_defined_vars();

echo "Done\n";
?>
