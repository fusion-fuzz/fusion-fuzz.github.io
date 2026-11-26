<?php
class test {
  protected function __destruct() {}
}
function startTransaction() {
    return (object)["errors" => []];
}
function captureTransaction($func) {
    $tx = startTransaction();
    try {
        return $func($tx);
    } catch (Throwable $e) {
        $tx->errors[] = $e->getMessage();
    }
}
function registerContinuation($promise, $tx) {
    $promise->then(
        function ($value) use ($tx) {},
        function ($e) use ($tx) {}
    );
}
class Promise extends test {
    public function then($onFulfilled, $onRejected = null) {
        if ($this->error !== null) {}
    }
}
captureTransaction(function ($tx) {});
captureTransaction(function () {
    $p = new Promise("ok");
    registerContinuation($p, (object)["errors" => []]);
});
