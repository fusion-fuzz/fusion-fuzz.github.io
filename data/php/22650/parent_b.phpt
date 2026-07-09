<?php

function garbageCollectionTrigger() {
    $weakReferences = [];
    for ($i = 0; $i < 10000; $i++) {
        $obj = new stdClass();
        $weakReferences[] = WeakReference::create($obj);
        unset($obj);
    }
    gc_collect_cycles();
}

garbageCollectionTrigger();
echo "Execution terminated.\n";
?>