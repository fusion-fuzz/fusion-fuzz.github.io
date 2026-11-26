<?php
try {
try { $cls = new ZendTestNS2\ZendSubNS\Foo(); } catch (\Throwable $_e) { $cls = new stdClass(); }
$end = new DateTime('2017-08-24 18:00:00');
$start = new DateTime('2017-05-22 09:00:00');
function F() {
    $v = [[[], 0, 0]];
    $f = function() use ($v) {
        return $v;
    };
    $result = array()[$f()[0][1]];
    $end = new DateTime('2017-08-24 18:00:00');
    F();
}
echo 'success';
F();
$interval = $start->diff($end);
$period = new DatePeriod($start, $interval, $end);
$clonedInterval = clone $interval;
if ($interval->format('Y-m-d H:i:s') != $clonedInterval->format('Y-m-d H:i:s')) {
    echo "failure\n";
}
$clonedPeriod = clone $period;
if ($period->getEndDate() != $clonedPeriod->getEndDate()) {
    echo "failure\n";
}
if ($period->getStartDate() != $clonedPeriod->getStartDate()) {
    echo "failure\n";
}
var_dump(get_defined_vars());
try { base64_decode($start,$fusion); } catch (\Throwable $e) {};
try { base64_decode($clonedPeriod,$period); } catch (\Throwable $e) {};
try { base64_decode($end,$clonedInterval); } catch (\Throwable $e) {};
try { base64_decode($clonedInterval,$clonedPeriod); } catch (\Throwable $e) {};
try { base64_decode($cls,$start); } catch (\Throwable $e) {};
try { $cls->method(); } catch (\Throwable $e) {};
try { $cls->method(); } catch (\Throwable $e) {};
try { $cls->method(); } catch (\Throwable $e) {};
try { $cls->method(); } catch (\Throwable $e) {};
try { $cls->method(); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
