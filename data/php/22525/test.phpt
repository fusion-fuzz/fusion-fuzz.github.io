--TEST--
Fused 171298a8 + f1d8288d
--INI--
assert.active = 0
assert.warning = 0
assert.callback = f1
assert.bail = 0
opcache.enable=1
opcache.enable_cli=1
opcache.optimization_level=-1
opcache.preload={PWD}/preload.inc
opcache.jit=1255
--FILE--
<?php
try {
var_dump((new ReflectionMethod('x', 'foo'))->getPrototype()->class);
?>
OK
function f1()
{
    echo "f1 called\n";
}
var_dump((new ReflectionMethod('x', 'bar'))->getPrototype()->class);
var_dump($r2=assert(0));
var_dump($r2=assert(1));
var_dump(get_defined_vars());
try { sodium_crypto_secretbox_open($r2,$r2,$fusion); } catch (\Throwable $e) {};
try { sodium_crypto_secretbox_open($r2,$r2,$fusion); } catch (\Throwable $e) {};
try { sodium_crypto_secretbox_open($fusion,$fusion,$fusion); } catch (\Throwable $e) {};
try { sodium_crypto_secretbox_open($r2,$fusion,$fusion); } catch (\Throwable $e) {};
try { sodium_crypto_secretbox_open($fusion,$r2,$fusion); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
