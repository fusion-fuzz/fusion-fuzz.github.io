<?php
class LType {
    public string $name;
    public function __construct(string $name) { $this->name = $name; }
}
class LTypes {
    public static LType $Bool;
    public static LType $Date;
    public static LType $Time;
    public static LType $Number;
    public static LType $String;
    public static LType $Array;
    public static LType $Map;
    public static LType $Null;
    public static LType $Object;
}
LTypes::$Bool = new LType('Bool');
LTypes::$Date = new LType('Date');
LTypes::$Time = new LType('Time');
LTypes::$Number = new LType('Number');
LTypes::$String = new LType('String');
LTypes::$Array = new LType('Array');
LTypes::$Map = new LType('Map');
LTypes::$Null = new LType('Null');
LTypes::$Object = new LType('Object');

class LObject {
    public LType $type;
    protected $value;
    public function __construct($value = null, ?LType $type = null) { $this->value = $value; $this->type = $type ?? LTypes::$Object; }
    public function getValue() { return $this->value; }
}
class LNumber extends LObject { public function __construct($v) { parent::__construct((float)$v, LTypes::$Number); } }
class LString extends LObject { public function __construct($v) { parent::__construct((string)$v, LTypes::$String); } }
class LBool extends LObject { public function __construct($v) { parent::__construct((bool)$v, LTypes::$Bool); } }
class LArray extends LObject { public function __construct($v) { parent::__construct($v, LTypes::$Array); } }
class LMap extends LObject { public function __construct($v) { parent::__construct($v, LTypes::$Map); } }

$args = [1, 2.5, "3", true, null, [new LNumber(4), new LString("5")], ["a" => 1, "b" => 2]];
for ($i = 0; $i < count($args); $i++) {
    $v = $args[$i];
    if ($v === null) $args[$i] = new LObject(null, LTypes::$Null);
    elseif (is_int($v) || is_float($v)) $args[$i] = new LNumber($v);
    elseif (is_string($v)) $args[$i] = new LString($v);
    elseif (is_bool($v)) $args[$i] = new LBool($v);
    elseif (is_array($v) && array_keys($v) === range(0, count($v) - 1)) $args[$i] = new LArray($v);
    elseif (is_array($v)) $args[$i] = new LMap($v);
}
$out = [];
foreach ($args as $v) $out[] = $v instanceof LObject ? $v->getValue() : $v;
echo json_encode($out), PHP_EOL;
?>