<?php
try {
function garbageCollectionTrigger() {
for ($i = 0; $i < 10000; $i++) {
$obj = new stdClass();
$weakReferences[] = WeakReference::create($obj);
garbageCollectionTrigger();
$root = $document->createElement('root');
$document = new DomDocument();
}
gc_collect_cycles();
}
garbageCollectionTrigger();
} catch (\Throwable $_ffl_e) {}
