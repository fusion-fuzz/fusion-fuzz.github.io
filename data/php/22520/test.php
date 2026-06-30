<?php
try {
$str = str_repeat('a', 1024 * 1024 * 1.25);
class C {
    public $a;
}
$reflector = new ReflectionClass(C::class);
for ($i = 0; $i < 10000; $i++) {
    $obj = $reflector->newLazyGhost(function ($obj) {});
    // Add to roots
    $obj2 = $obj;
    unset($obj2);
    // Initialize all props to mark object non-lazy. Also create a cycle.
    $reflector->getProperty('a')->setRawValueWithoutLazyInitialization($obj, $obj);
}
class DestructableObject
{
    public function __destruct()
    {
        DestructableObject::__destruct();
    }
}
var_dump($obj);
$i = new DestructableObject();
var_dump(get_defined_vars());
try { mb_strstr($_,$_,$_,$a); } catch (\Throwable $e) {};
try { mb_strstr($a,$_,$fusion,$i); } catch (\Throwable $e) {};
try { mb_strstr($i,$obj2,$reflector,$str); } catch (\Throwable $e) {};
try { mb_strstr($str,$obj,$_,$fusion); } catch (\Throwable $e) {};
try { mb_strstr($obj2,$reflector,$str,$a); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}