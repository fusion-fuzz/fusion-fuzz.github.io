<?php
try {
class MySoapClient extends SoapClient {
public function __doRequest($request, $location, $action, $version, $one_way = false, ?string $uriParserClass = null): string {
return '';
}
}
function main() {
for (;;) {
$soap = new MySoapClient(
null,
array(
'location' => "http://localhost/soap.php",
'uri' => "http://localhost/",
)
);
$soap->call(1.1);
main();
}
}
$soap = new MySoapClient(
null,
array(
'location' => "http://localhost/soap.php",
'uri' => "http://localhost/",
)
);
main();
} catch (\Throwable $_ffl_e) {}
