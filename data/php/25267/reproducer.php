<?php
class C extends SoapClient {
    function __doRequest($request, $location, $action, $version, $one_way = false, ?string $uriParserClass = null): string { return ""; }
}
$c = new C(null, ["location" => "test://", "uri" => "test://"]);
$c->foo(new SoapVar([new SoapVar("x", XSD_STRING)], XSD_ANYXML));
