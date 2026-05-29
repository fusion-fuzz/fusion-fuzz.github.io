--TEST--
Fused 34c83049 + e95a182d
--INI--
opcache.enable=0
--FILE--
<?php
try {
error_reporting(E_ALL);
class foo {
    public $x = array(1);
    public function &b() {
        return $this->x;
    }
}
$foo = new foo;
$a = 'b';
var_dump($foo->$a()[0]);
$h = &$foo->$a();
$h[] = 2;
var_dump($foo->$a());
function findNthMostRepeatedElement(array $numbers, int $position): int {
    validateInput($numbers, $position);
    $result = null;
    $counter = [];
    foreach ($numbers as $i) {
        if (!isset($counter[$i])) {
            $counter[$i] = 1;
        } else {
            $counter[$i]++;
        }
    }
    foreach ($counter as $candidate => $count) {
        if ($count === $position) {
            $result = $candidate;
            break;
        }
    }
    validateResult($result);
    return $result;
}
function validateInput(array $numbers, int $position): void {
    if (count($numbers) === 0 || $position <= 0) {
        throw new InvalidArgumentException("You can't pass empty arrays or position values less than 1 as parameter.");
    }
}
function validateResult(?int $result): void {
    if ($result === null) {
        throw new InvalidArgumentException("There are no elements repeated n times in the array passed as argument");
    }
}
$numbers = [1, 2, 2, 3, 3, 3, 4];
$position = 2;
$result = findNthMostRepeatedElement($numbers, $position);
echo $result;
var_dump(get_defined_vars());
try { zend_call_method_if_exists($h,$x,$fusion); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($foo,$a,$a); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($fusion,$x,$a); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($fusion,$a,$x); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($a,$foo,$fusion); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
