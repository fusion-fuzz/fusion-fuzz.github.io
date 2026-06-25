<?php

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

$rowCount = 0;
$ROWS = 5;
$COLS = 3;

$processor = new BasicRowProcessor();
$rs = [
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6']
];

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