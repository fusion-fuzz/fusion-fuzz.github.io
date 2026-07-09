<?php
try {
try { $cls = new DOMComment(); } catch (\Throwable $_e) { $cls = new stdClass(); }
try { $clsAttr=$cls->namespaceURI; } catch (\Throwable $_e) {}
echo "Execution terminated.\n";
$document = new DomDocument();
function garbageCollectionTrigger() {
    $weakReferences = [];
    for ($i = 0; $i < 10000; $i++) {
        $obj = new stdClass();
        $weakReferences[] = WeakReference::create($obj);
    garbageCollectionTrigger();
    $root = $document->createElement('root');
    $document = new DomDocument();
        unset($obj);
    }
    gc_collect_cycles();
}
garbageCollectionTrigger();
$root = $document->createElement('root');
try {
    $root->attributes[][] = null;
} catch (Throwable $e) {
    echo $e->getMessage(), "\n";
}
$document->appendChild($root);
var_dump($root->attributes->length);
$root->setAttribute('attrib', 'value');
// Consistent with the method call
try {
    var_dump($root->attributes[-1]);
} catch (ValueError $e) {
    echo $e->getMessage(), "\n";
}
var_dump(get_defined_vars());
try { $cls->__construct($document); } catch (\Throwable $e) {};
try { $cls->__construct($root); } catch (\Throwable $e) {};
try { $cls->__construct($e); } catch (\Throwable $e) {};
try { $cls->__construct($document); } catch (\Throwable $e) {};
try { $cls->__construct($fusion); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}