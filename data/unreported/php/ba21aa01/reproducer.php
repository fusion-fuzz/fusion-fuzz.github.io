<?php
try {
$baseDir = sys_get_temp_dir();
$sourceExcerpt = [];
$start = microtime(true);
$end = microtime(true);
$count = 0;
$srcBasePath = $baseDir . '/IPCT.testOverTCP.source';
$messageCount = 2 * 1000 * 1000;
$timeTaken = ($end - $start) * 1e6;
$averageTime = $timeTaken / $messageCount;
class PriceReader {
    private $excerpt;
    private $listener;
    public function __construct(&$excerpt, $listener) {
        $this->excerpt = &$excerpt;
        $this->listener = $listener;
    }
    public function read() {
        if (empty($this->excerpt)) return false;
        $update = array_shift($this->excerpt);
        ($this->listener)($update);
        return true;
    }
}
$snkBasePath = $baseDir . '/IPCT.testOverTCP.sink';
class PriceUpdate {
    public $timeInMicros;
    public $symbol;
    public $bp;
    public $bq;
    public $ap;
    public $aq;
    public function __construct($timeInMicros, $symbol, $bp, $bq, $ap, $aq) {
        $this->timeInMicros = $timeInMicros;
        $this->symbol = $symbol;
        $this->bp = $bp;
        $this->bq = $bq;
        $this->ap = $ap;
        $this->aq = $aq;
    }
}
$reader = new PriceReader($sourceExcerpt, function($priceUpdate) use (&$count) {
    $count++;
});
echo sprintf("Average time per message: %.2f µs\n", $averageTime);
class PriceWriter {
    private $excerpt;
    public function __construct($excerpt) {
        $this->excerpt = $excerpt;
    }
    public function onPrice($timeInMicros, $symbol, $bp, $bq, $ap, $aq) {
        $this->excerpt[] = new PriceUpdate($timeInMicros, $symbol, $bp, $bq, $ap, $aq);
    }
}
while (!empty($sourceExcerpt)) {
    $reader->read();
}
$writer = new PriceWriter($sourceExcerpt);
for ($i = 1; $i <= $messageCount; $i++) {
    $writer->onPrice($i, "symbol", 99.9, $i, 100.1, $i + 1);
}
class foo {
    function __unset($a) {
        print "unset\n";
        var_dump($a);
    }
    public function __call($a, $b) {
        print "call\n";
        var_dump($a);
    }
    function __clone() {
        print "clone\n";
    }
    static public function __callstatic($a, $b) {
        print "callstatic\n";
    }
    public function __tostring() {
        return 'foo';
    }
}
$a = new foo;
$a->sdfdsa();
$a::test();
clone $a;
var_dump((string)$a);
unset($a->a);
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
