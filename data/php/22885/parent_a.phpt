<?php

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

class StubConnection {
    public function close() {
        // Closing logic
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