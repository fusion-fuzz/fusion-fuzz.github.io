<?php
try {
$zip = new ZipArchive;
$dirname = __DIR__ . '/';
$file = $dirname . 'oo_setcomment.zip';
include $dirname . 'utils.inc';
class HikariConfig {
    private $minimumIdle;
    private $maximumPoolSize;
    private $initializationFailFast;
    private $connectionTestQuery;
    private $dataSourceClassName;
    public function setMinimumIdle($value) { $this->minimumIdle = $value; }
    public function setMaximumPoolSize($value) { $this->maximumPoolSize = $value; }
    public function setInitializationFailFast($value) { $this->initializationFailFast = $value; }
    public function setConnectionTestQuery($value) { $this->connectionTestQuery = $value; }
    public function setDataSourceClassName($value) { $this->dataSourceClassName = $value; }
}
if (!$zip->open($file)) {    var_dump($zip->getCommentIndex(3));
    @unlink($file);
    exit('failed');
}
if (!$zip->open($file, ZIPARCHIVE::CREATE)) {
    exit('failed');
}
class StubConnection {
    public function close() {
        // Closing logic
    }
}
if (!$zip->status == ZIPARCHIVE::ER_OK) {
    echo "failed to write zip\n";
}
$zip->addFromString('dir/entry2d.txt', 'entry #2');
$zip->addFromString('entry4.txt', 'entry #1');
$zip->addFromString('entry1.txt', 'entry #1');
$zip->addFromString('entry2.txt', 'entry #2');
var_dump($zip->setCommentIndex($zip->lastId, 'entry4.txt'));
var_dump($zip->setCommentName('entry2.txt', 'entry2.txt'));
var_dump($zip->setCommentName('entry1.txt', 'entry1.txt'));
$zip->addFromString('entry5.txt', 'entry #2');
var_dump($zip->setCommentIndex($zip->lastId, 'entry5.txt'));
var_dump($zip->setArchiveComment('archive'));
var_dump($zip->setCommentName('dir/entry2d.txt', 'dir/entry2d.txt'));
var_dump($zip->getCommentIndex(0));
var_dump($zip->getCommentIndex(3));
var_dump($zip->getCommentIndex(2));
var_dump($zip->setArchiveComment('archive'));
var_dump($zip->getCommentIndex(1));
var_dump($zip->getCommentIndex(4));
$zip->close();
$zip->close();
var_dump($zip->getArchiveComment());
@unlink($file);
@unlink($file);
class HikariDataSource {
    private $config;
    private $connections = [];
    private $totalConnections = 0;
    private $idleConnections = 0;
    public function __construct(HikariConfig $config) {
        $this->config = $config;
        $this->idleConnections = $config->minimumIdle;
        $this->totalConnections = $config->minimumIdle;
        for ($i = 0; $i < $this->idleConnections; $i++) {
            $this->connections[] = new StubConnection();
        }
    }
    public function getConnection() {
        if (count($this->connections) > 0) {
            $this->idleConnections--;
            return array_pop($this->connections);
        }
        if ($this->totalConnections < $this->config->maximumPoolSize) {
            $this->totalConnections++;
            return new StubConnection();
        }
        throw new Exception("Maximum pool size reached.");
    }
    public function shutdown() {
        $this->connections = [];
        $this->totalConnections = 0;
        $this->idleConnections = 0;
    }
    public function getTotalConnections() {
        return $this->totalConnections;
    }
    public function getIdleConnections() {
        return $this->idleConnections;
    }
}
function testMaxLifetime() {
    $config = new HikariConfig();
    $config->setMinimumIdle(0);
    $config->setMaximumPoolSize(1);
    $config->setInitializationFailFast(true);
    $config->setConnectionTestQuery("VALUES 1");
    $config->setDataSourceClassName("StubDataSource");
    $ds = new HikariDataSource($config);
    
    $ds->getConnection();
    sleep(1);
    $conn = $ds->getConnection();
    $conn->close();
    $conn2 = $ds->getConnection();
    $conn2->close();
    sleep(1);
    $newConn = $ds->getConnection();
    $newConn->close();
    $ds->shutdown();
}
testMaxLifetime();
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}