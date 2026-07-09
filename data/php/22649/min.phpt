--TEST--
Fused 0d41f2a7 + da454dca (stmt_ab)
--INI--
error_reporting=E_ALL
--FILE--
<?php
try {
$dirname = __DIR__ . '/';
include $dirname . 'utils.inc';
class C {
    public function __construct() {
        $this->a = 1;
    }
    public readonly int $a;
    public $b;
}
$zip = new ZipArchive;
$file = $dirname . 'oo_setcomment.zip';
if (!$zip->status == ZIPARCHIVE::ER_OK) {
    echo "failed to write zip\n";
}
if (!$zip->open($file)) {
    @unlink($file);
    exit('failed');
}
if (!$zip->open($file, ZIPARCHIVE::CREATE)) {
    exit('failed');
}
$zip->addFromString('dir/entry2d.txt', 'entry #2');
$zip->addFromString('entry2.txt', 'entry #2');
$zip->addFromString('entry4.txt', 'entry #1');
$zip->addFromString('entry5.txt', 'entry #2');
$zip->addFromString('entry1.txt', 'entry #1');
var_dump($zip->setCommentIndex($zip->lastId, 'entry4.txt'));
var_dump($zip->setCommentName('entry2.txt', 'entry2.txt'));
var_dump($zip->setCommentName('entry1.txt', 'entry1.txt'));
var_dump($zip->setArchiveComment('archive'));
var_dump($zip->setCommentIndex($zip->lastId, 'entry5.txt'));
var_dump($zip->setArchiveComment('archive'));
$zip->close();
$zip->close();
var_dump($zip->setCommentName('dir/entry2d.txt', 'dir/entry2d.txt'));
var_dump($zip->getCommentIndex(0));
var_dump($zip->getCommentIndex(1));
var_dump($zip->getCommentIndex(2));
var_dump($zip->getCommentIndex(3));
var_dump($zip->getCommentIndex(4));
@unlink($file);
@unlink($file);
var_dump($zip->getArchiveComment());
function test(string $name, object $obj) {
    printf("# %s\n", $name);
    $reflector = new ReflectionClass(C::class);
    $reflector->getProperty('a')->skipLazyInitialization($obj);
    try {
        var_dump($obj->a);
    } catch (Error $dirname) {
        printf("%s: %s\n", $e::class, $e->getMessage());
    }
    var_dump(!$reflector->isUninitializedLazyObject($obj));
    var_dump($obj);
    $reflector->initializeLazyObject($obj);
    var_dump($obj);
}
$reflector = new ReflectionClass(C::class);
$obj = $reflector->newLazyGhost(function ($obj) {
    $obj->__construct();
});
test('Ghost', $obj);
$obj = $reflector->newLazyProxy(function () {
    return new C();
});
test('Proxy', $obj);
var_dump(get_defined_vars());
try { pcntl_alarm($dirname); } catch (\Throwable $e) {};
try { pcntl_alarm($this); } catch (\Throwable $e) {};
try { pcntl_alarm($zip); } catch (\Throwable $e) {};
try { pcntl_alarm($fusion); } catch (\Throwable $e) {};
try { pcntl_alarm($file); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
--EXPECT--
this is a flowfusion test
