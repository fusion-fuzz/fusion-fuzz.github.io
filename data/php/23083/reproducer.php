<?php
try {
var_dump(is_dir('file:///datafoo:test'));
var_dump(is_dir('datafoo:test'));
var_dump(file_get_contents('data:text/plain,foo'));
var_dump(file_get_contents('datafoo:text/plain,foo'));
require_once dirname(__DIR__) . "/test_setup/test_helpers.inc";
$stmt = mysqli_prepare($link, "INSERT INTO insert_bind_char_text VALUES (?,?)");
mysqli_stmt_bind_param($stmt, "ss", $q1, $q2);
$test = array($c1,$c2);
} catch (\Throwable $_ffl_e) {}
