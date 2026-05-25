<?php
try {
try { $cls = new LibXMLError(); } catch (\Throwable $_e) { $cls = new stdClass(); }
try { $clsAttr=$cls->code; } catch (\Throwable $_e) {}
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
class Player {
    public $name;
    public $world;
    function __construct($name, $world) {
        $this->name = $name;
        $this->world = $world;
    }
    function teleport($location) {
        // Simulate teleporting the player
        echo "Teleported " . $this->name . " to " . $location->x . "," . $location->y . "," . $location->z . "\n";
    }
}
class Location {
    public $world;
    public $x;
    public $y;
    public $z;
    function __construct($world, $x, $y, $z) {
        $this->world = $world;
        $this->x = $x;
        $this->y = $y;
        $this->z = $z;
    }
}
function getInteger($value, $min, $max) {
    $intValue = intval($value);
    if ($intValue < $min || $intValue > $max) {
        return null;
    }
    return $intValue;
}
$world = "world";
$player = new Player("Steve", $world);
$args = ["Steve", "30000001", "0", "30000001"]; // simulate input args
if (count($args) < 1 || count($args) > 4) {
    echo "Usage: /tp [player] <target>\n/tp [player] <x> <y> <z>\n";
    exit;
}
if (count($args) == 1 || count($args) == 3) {
    // Simulating sender being a player
} else {
    $target = new Player($args[0], $world); // simulate getting target player
}
if (!isset($target)) {
    echo "Player not found: " . $args[0] . "\n";
}
if (count($args) < 3) {
    // Simulate finding target player
    $target = new Player($args[count($args) - 1], $world); // simulate getting target player
    if (!isset($target)) {
        echo "Can't find user " . $args[count($args) - 1] . ". No tp.\n";
    }
    $player->teleport($target);
} else if ($player->world != null) {
    $x = getInteger($args[count($args) - 3], -30000000, 30000000);
    $y = getInteger($args[count($args) - 2], 0, 256);
    $z = getInteger($args[count($args) - 1], -30000000, 30000000);
    $location = new Location($player->world, $x, $y, $z);
    $player->teleport($location);
}
var_dump(get_defined_vars());
try { deflate_init($fusion,$fusion); } catch (\Throwable $e) {};
try { deflate_init($cls,$cls); } catch (\Throwable $e) {};
try { deflate_init($clsAttr,$fusion); } catch (\Throwable $e) {};
try { deflate_init($clsAttr,$clsAttr); } catch (\Throwable $e) {};
try { deflate_init($fusion,$cls); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}