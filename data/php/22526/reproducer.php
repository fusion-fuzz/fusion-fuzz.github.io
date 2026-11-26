<?php
try {
function main() {
for ($i = 0; $i < 10000; $i++) {
$code .= '  return function() {' . PHP_EOL;
}
try {
eval($code);
} catch (ParseError $e) {
main();
}
}
main();
} catch (\Throwable $_ffl_e) {}
