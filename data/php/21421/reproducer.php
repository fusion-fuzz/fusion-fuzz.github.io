<?php
class TestSoapClient extends SoapClient{
}
$options=Array(
'uri'      => 'http://schemas.nothing.com',
'location' => 'test://',
'typemap'  => array(array("type_ns"   => "http://schemas.nothing.com",
"type_name" => "book",
"from_xml"  => "book_from_xml"))
);
$client = new TestSoapClient(NULL, $options);
$p4_obj = (object)(array)$client;
$p4_ser    = serialize($p4_obj);
$p4_deser  = unserialize($p4_ser);
var_dump($p4_deser == $p4_obj);
