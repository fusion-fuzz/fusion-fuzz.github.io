<?php
try {
$proc = new XSLTProcessor();
foreach ([1,-1] as $value) {
    echo "--- Set to $value ---\n";
    try {
        $proc->maxTemplateDepth = $value;
    } catch (ValueError $e) {
        echo $e->getMessage(), "\n";
    }
}
echo "--- Get reference ---\n";
try {
    $ref =& $proc->maxTemplateDepth;
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}
echo "--- Unset ---\n";
try {
    unset($proc->maxTemplateDepth);
} catch (Error $e) {
    echo $e->getMessage(), "\n";
}
echo "--- Dump ---\n";
var_dump($proc);
$fusion = $value;
class A {
    public function process($call) {
        $i = 0;
        foreach (array("a", "b", "c") as $attr) {
            $call($i++, "xxx");
        }
    }
}
$a = new A();
$a->process(function($i, $fusion) { var_dump($i); });
var_dump(get_defined_vars());
try { zend_terminate_string($value); } catch (\Throwable $e) {};
try { zend_terminate_string($proc); } catch (\Throwable $e) {};
try { zend_terminate_string($fusion); } catch (\Throwable $e) {};
try { zend_terminate_string($call); } catch (\Throwable $e) {};
try { zend_terminate_string($e); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
