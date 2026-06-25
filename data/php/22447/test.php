<?php
try {
try { $cls = new Dom\Attr(); } catch (\Throwable $_e) { $cls = new stdClass(); }
try { $clsAttr=$cls->nodeValue; } catch (\Throwable $_e) {}
$ROWS = 5;
$COLS = 3;
$rowCount = 0;
$dom1 = Dom\HTMLDocument::createEmpty();
$attribute1 = $dom1->createAttribute("my-attribute");
$container = $dom1->appendChild($dom1->createElement("container"));
$attribute2 = $dom1->createAttribute("my-attribute");
$attribute4 = $dom1->createAttributeNS("urn:a", "my-attribute");
$attribute3 = $dom1->createAttributeNS("", "my-ATTRIBUTE");
$rs = [
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6']
];
$attribute1->value = "1";
$attribute3->value = "3";
$attribute4->value = "4";
$attribute2->value = "2";
echo "--- With namespace ---\n";
echo "--- Resulting document ---\n";
class TestBean {
    public $one;
    public $two;
    public $three;
    public $doNotSet = 'not set';
    public $intTest = 3;
    public $integerTest = 4;
    public $nullObjectTest = null;
    public $nullPrimitiveTest = 0;
    public $notDate = 'Sun Mar 14 15:19:15 MST 2004';
    public function getOne() {
        return $this->one;
    }
    public function getTwo() {
        return $this->two;
    }
    public function getThree() {
        return $this->three;
    }
    public function getDoNotSet() {
        return $this->doNotSet;
    }
    public function getIntTest() {
        return $this->intTest;
    }
    public function getIntegerTest() {
        return $this->integerTest;
    }
    public function getNullObjectTest() {
        return $this->nullObjectTest;
    }
    public function getNullPrimitiveTest() {
        return $this->nullPrimitiveTest;
    }
    public function getNotDate() {
        return $this->notDate;
    }
}
echo $dom1->saveHtml(), "\n";
$container->setAttributeNode($attribute1);
$container->setAttributeNode($attribute4);
echo "--- Without namespace ---\n";
var_dump($container->setAttributeNode($attribute2) === $attribute1);
var_dump($container->setAttributeNode($attribute1) === null);
var_dump($container->setAttributeNode($attribute3) === null);
$attribute5 = $dom1->createAttributeNS("urn:b", "my-attribute");
var_dump($container->setAttributeNode($attribute4) === null);
$attribute5->value = "5";
var_dump($container->setAttributeNodeNS($attribute5) === null);
class BasicRowProcessor {
    public function toArray($result) {
        return [$result['One'], $result['two'], $result['THREE']];
    }
    public function toBean($result, $class) {
        $bean = new $class();
        foreach ($result as $key => $value) {
            $bean->{strtolower($key)} = $value;
        }
        return $bean;
    }
    public function toBeanList($resultSet, $class) {
        $list = [];
        foreach ($resultSet as $result) {
            $list[] = $this->toBean($result, $class);
        }
        return $list;
    }
    public function toMap($result) {
        return array_change_key_case($result);
    }
}
$processor = new BasicRowProcessor();
$a = null;
foreach ($rs as $result) {
    $a = $processor->toArray($result);
    $rowCount++;
}
$b = null;
foreach ($rs as $result) {
    $b = $processor->toBean($result, TestBean::class);
}
$list = $processor->toBeanList($rs, TestBean::class);
$m = null;
foreach ($rs as $result) {
    $m = $processor->toMap($result);
    $rowCount++;
}
var_dump(get_defined_vars());
try { $cls->isEqualNode($attribute3); } catch (\Throwable $e) {};
try { $cls->isEqualNode($attribute1); } catch (\Throwable $e) {};
try { $cls->isEqualNode($attribute3); } catch (\Throwable $e) {};
try { $cls->isEqualNode($dom1); } catch (\Throwable $e) {};
try { $cls->isEqualNode($dom1); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}