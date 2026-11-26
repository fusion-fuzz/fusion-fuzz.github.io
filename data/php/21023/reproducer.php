<?php
include 'server.inc';
$host = curl_cli_server_start();
$url = "{$host}/get.inc";
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_NOPROGRESS, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_XFERINFOFUNCTION, $callback);
echo curl_exec($ch), PHP_EOL;
var_dump(get_defined_vars());
