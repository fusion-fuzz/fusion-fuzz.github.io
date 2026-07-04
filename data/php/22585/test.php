<?php
try {
class MySoapClient extends SoapClient {
    public function __doRequest($request, $location, $action, $version, $one_way = false, ?string $uriParserClass = null): string {
        echo $request, "\n";
        return '';
    }
}
function main() {
    $i = 0;
    for (;;) { 
    $soap = new MySoapClient(
    null,
    array(
        'location' => "http://localhost/soap.php",
        'uri' => "http://localhost/",
        'style' => SOAP_RPC,
        'trace' => true,
        'exceptions' => false,
    )
);
    $soap->call(1.1);
    main();
        $i++;
    }
}
$soap = new MySoapClient(
    null,
    array(
        'location' => "http://localhost/soap.php",
        'uri' => "http://localhost/",
        'style' => SOAP_RPC,
        'trace' => true,
        'exceptions' => false,
    )
);
main();
$soap->call(1.1);
ini_set('precision', -1);
var_dump(get_defined_vars());
try { mb_get_info($one_way); } catch (\Throwable $e) {};
try { mb_get_info($location); } catch (\Throwable $e) {};
try { mb_get_info($one_way); } catch (\Throwable $e) {};
try { mb_get_info($location); } catch (\Throwable $e) {};
try { mb_get_info($action); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}