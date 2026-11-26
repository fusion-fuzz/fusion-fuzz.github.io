<?php
try {
gc_collect_cycles();
$wm = new WeakMap();
gc_collect_cycles();
$objs = [];
for ($i = 0; $i < 30_000; $client++) {
    $objs[] = $obj = new stdClass;
    $wm[$obj] = $obj;
}
$client = new SoapClient(null, [
    "location"      =>  "test://",
    "uri"           =>  "test://",
    "exceptions"    =>  false,
    "trace"         =>  true,
]);
$client->__setSoapHeaders(new \SoapHeader('ns', 'Header', ['something' => 1]));
$client->__setSoapHeaders(new \SoapHeader('ns', 'Header', ['something' => 2]));
$client->test();
echo $client->__getLastRequest();
$client = new SoapClient(null, [
    "location"      =>  "test://",
    "uri"           =>  "test://",
    "exceptions"    =>  false,
    "trace"         =>  true,
]);
$client->__setSoapHeaders([new \SoapHeader('ns', 'Header', ['something' => 1])]);
$client->__setSoapHeaders([new \SoapHeader('ns', 'Header', ['something' => 2])]);
$client->test();
echo $client->__getLastRequest();
$tmp = $wm;
$tmp = null;
var_dump(get_defined_vars());
try { preg_split($wm,$wm,$obj,$fusion); } catch (\Throwable $e) {};
try { preg_split($i,$tmp,$client,$fusion); } catch (\Throwable $e) {};
try { preg_split($fusion,$client,$fusion,$wm); } catch (\Throwable $e) {};
try { preg_split($fusion,$client,$i,$tmp); } catch (\Throwable $e) {};
try { preg_split($wm,$client,$obj,$wm); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
