<?php
$pdo = new PDO("sqlite::memory:");
$pdo->exec("CREATE TABLE t(a TEXT, b TEXT)");
$stmt = $pdo->prepare("INSERT INTO t VALUES(:a, :b)");
$stmt->execute([":a" => str_repeat("x", 10), ":b" => str_repeat("y", 10)]);
$stmt->execute([":a" => "z"]);
var_dump($pdo->query("SELECT * FROM t")->fetchAll(PDO::FETCH_NUM));
