<?php
define('ROW', 10);
define('COL', 10);
function initialize_board(&$board) {
for ($i = 0; $i < ROW; $i++) {
for ($j = 0; $j < COL; $j++) {
$board[$i][$j] = rand(0, 1);
}
}
}
function print_board($board) {
for ($i = 0; $i < ROW; $i++) {
for ($j = 0; $j < COL; $j++) {
echo $board[$i][$j] . " ";
}
echo "\n";
}
}
function count_live_neighbors($board, $row, $col) {
$live_neighbors = 0;
if ($row - 1 >= 0 && $board[$row - 1][$col] == 1) $live_neighbors++;
if ($row + 1 < ROW && $board[$row + 1][$col] == 1) $live_neighbors++;
if ($col - 1 >= 0 && $board[$row][$col - 1] == 1) $live_neighbors++;
if ($col + 1 < COL && $board[$row][$col + 1] == 1) $live_neighbors++;
if ($row - 1 >= 0 && $col - 1 >= 0 && $board[$row - 1][$col - 1] == 1) $live_neighbors++;
if ($row - 1 >= 0 && $col + 1 < COL && $board[$row - 1][$col + 1] == 1) $live_neighbors++;
if ($row + 1 < ROW && $col - 1 >= 0 && $board[$row + 1][$col - 1] == 1) $live_neighbors++;
if ($row + 1 < ROW && $col + 1 < COL && $board[$row + 1][$col + 1] == 1) $live_neighbors++;
return $live_neighbors;
}
$board = array();
srand(time());
initialize_board($board);
print_board($board);
echo "\n";
for ($t = 0; $t < 10; $t++) {
$new_board = array();
for ($i = 0; $i < ROW; $i++) {
for ($j = 0; $j < COL; $j++) {
$live_neighbors = count_live_neighbors($board, $i, $j);
if ($board[$i][$j] == 1 && ($live_neighbors < 2 || $live_neighbors > 3))
$new_board[$i][$j] = 0;
else if ($board[$i][$j] == 0 && $live_neighbors == 3)
$new_board[$i][$j] = 1;
else
$new_board[$i][$j] = $board[$i][$j];
}
}
for ($i = 0; $i < ROW; $i++) {
for ($j = 0; $j < COL; $j++) {
$board[$i][$j] = $new_board[$i][$j];
}
}
print_board($board);
echo "\n";
}
echo (1%1.5)-(1.5%1%1%-1)-1;
var_dump(get_defined_vars());
