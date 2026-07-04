<?php
class MySoapClient extends SoapClient {
    public function __doRequest($request, $location, $action, $version, $one_way = false, ?string $uriParserClass = null): string {
        echo $request, "\n";
        return '';
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
ini_set('precision', -1);
$soap->call(1.1);
?>