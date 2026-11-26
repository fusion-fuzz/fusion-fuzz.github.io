<?php
$db = dba_popen(__DIR__ . "/out358.cdb", "n", "cdb");
dba_insert("a", "Inserted", $db);
