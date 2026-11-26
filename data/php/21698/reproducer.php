<?php
$zip = new ZipArchive();
$zip->addGlob(__FILE__, 0, []);
