<?php
try {
$users = [
    ['Id' => 1, 'FirstName' => 'John', 'Surname' => 'Smith', 'JobTitle' => 'Sales Associate', 'Email' => 'john.smith1@test.com'],
    ['Id' => 2, 'FirstName' => 'John', 'Surname' => 'Doe', 'JobTitle' => 'Sales Associate', 'Email' => 'john.doe@test.com'],
    ['Id' => 3, 'FirstName' => 'John', 'Surname' => 'Brown', 'JobTitle' => 'Sales Associate', 'Email' => 'john.brown@test.com'],
    ['Id' => 4, 'FirstName' => 'John', 'Surname' => 'Taylor', 'JobTitle' => 'Sales Associate', 'Email' => 'john.taylor@test.com'],
    ['Id' => 5, 'FirstName' => 'John', 'Surname' => 'Wilson', 'JobTitle' => 'Sales Associate', 'Email' => 'john.wilson@test.com'],
    ['Id' => 6, 'FirstName' => 'Johnny', 'Surname' => 'Burns', 'JobTitle' => 'Clerk', 'Email' => 'johnny.burns@test.com'],
    ['Id' => 7, 'FirstName' => 'Johnson', 'Surname' => 'Burns', 'JobTitle' => 'Manager', 'Email' => 'johnson.burns@test.com'],
    ['Id' => 8, 'FirstName' => 'Johnathan', 'Surname' => 'Burns', 'JobTitle' => 'Analyst', 'Email' => 'johnathan.burns@test.com'],
    ['Id' => 9, 'FirstName' => 'Jeremy', 'Surname' => 'Burns', 'JobTitle' => 'Writer', 'Email' => 'jeremy.burns@test.com'],
    ['Id' => 10, 'FirstName' => 'Jeremy', 'Surname' => 'Burns', 'JobTitle' => 'Editor', 'Email' => 'jeremy.burns2@test.com'],
];
$index = [];
foreach ($users as $u) {
    $index[] = $u;
}
$search = 'John';
$field = 'FirstName';
$results = [];
foreach ($index as $u) {
    if (strpos($u[$field], $search) !== false) {
        $results[] = ['Entity' => $u, 'Score' => 1];
    }
}
$skip = 4;
$take = 1;
$sub = array_slice($results, $skip, $take);
$wild = [];
foreach ($index as $u) {
    if (preg_match('/^Joh/i', $u['FirstName'])) {
        $wild[] = $u;
    }
}
$multi = [];
foreach ($index as $u) {
    if (strpos($u['FirstName'], 'Burns') !== false || strpos($u['Surname'], 'Burns') !== false) {
        $score = 0;
        if (strpos($u['FirstName'], 'Burns') !== false) $score += 2;
        if (strpos($u['Surname'], 'Burns') !== false) $score += 1;
        $multi[] = ['Entity' => $u, 'Score' => $score];
    }
}
usort($multi, function ($a, $b) {
    return $b['Score'] <=> $a['Score'];
});
$newUser = ['Id' => 11, 'FirstName' => 'Duke', 'Surname' => 'Nukem', 'JobTitle' => 'Shooty Man', 'Email' => 'duke.nukem@test.com'];
$before = [];
foreach ($index as $u) {
    if (strpos($u['Surname'], 'Nukem') !== false) $before[] = $u;
}
$index[] = $newUser;
$after = [];
foreach ($index as $u) {
    if (strpos($u['Surname'], 'Nukem') !== false) $after[] = $u;
}
echo count($results) . "\n";
echo count($sub) . "\n";
echo count($wild) . "\n";
echo count($multi) . "\n";
echo count($before) . ":" . count($after) . "\n";
echo $multi[0]['Entity']['FirstName'] . " " . $multi[0]['Entity']['Surname'] . "\n";
echo $multi[0]['Entity']['JobTitle'] . "\n";
define("MAX_64Bit", 9223372036854775807);
define("MAX_32Bit", 2147483647);
define("MIN_64Bit", -9223372036854775807 - 1);
define("MIN_32Bit", -2147483647 - 1);
$longVals = array(
    MAX_64Bit, MIN_64Bit, MAX_32Bit, MIN_32Bit, MAX_64Bit - MAX_32Bit, MIN_64Bit - MIN_32Bit,
    MAX_32Bit + 1, MIN_32Bit - 1, MAX_32Bit * 2, (MAX_32Bit * 2) + 1, (MAX_32Bit * 2) - 1,
    MAX_64Bit -1, MAX_64Bit + 1, MIN_64Bit + 1, MIN_64Bit - 1
);
foreach ($longVals as $longVal) {
   echo "--- testing: $longVal ---\n";
   var_dump(sin($longVal));
}
var_dump(get_defined_vars());
try { date_sunset($fusion,$longVal,$longVals,$longVal,$longVals,$longVals); } catch (\Throwable $e) {};
try { date_sunset($longVal,$fusion,$longVal,$fusion,$fusion,$fusion); } catch (\Throwable $e) {};
try { date_sunset($longVals,$fusion,$fusion,$longVal,$fusion,$longVals); } catch (\Throwable $e) {};
try { date_sunset($longVals,$fusion,$longVals,$longVal,$fusion,$longVals); } catch (\Throwable $e) {};
try { date_sunset($longVals,$longVal,$longVal,$longVal,$longVals,$longVals); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
