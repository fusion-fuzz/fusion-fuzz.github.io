*Fusion-Fuzz Bug Report*

**ID:** `10acb0c5` &nbsp;·&nbsp; **Signature:** `SUMMARY: AddressSanitizer: SEGV (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x606694) in __asan::Allocator::Deallocate(void*, unsigned long, unsigned long, __sanitizer::BufferedStackTrace*, __asan::AllocType)` &nbsp;·&nbsp; **RC:** `1`

The following code:

```php
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
```

Resulted in this output:

```
AddressSanitizer:DEADLYSIGNAL
=================================================================
==2361207==ERROR: AddressSanitizer: SEGV on unknown address 0x00000700002d (pc 0x000000606694 bp 0x000000000000 sp 0x7ffec99c5860 T0)
==2361207==The signal is caused by a WRITE memory access.
    #0 0x606694 in __asan::Allocator::Deallocate(void*, unsigned long, unsigned long, __sanitizer::BufferedStackTrace*, __asan::AllocType) (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x606694)
    #1 0x6805a5 in free (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x6805a5)
    #2 0x7f23ad1729b0  (/lib/x86_64-linux-gnu/libzip.so.4+0x59b0)
    #3 0x7f23ad176542 in zip_discard (/lib/x86_64-linux-gnu/libzip.so.4+0x9542)
    #4 0x7f23ad17b830 in zip_close (/lib/x86_64-linux-gnu/libzip.so.4+0xe830)
    #5 0x475597d in php_zipobj_close /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/zip/php_zip.c:592:13
    #6 0x4758f72 in zim_ZipArchive_close /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/zip/php_zip.c:1614:2
    #7 0x5b7d5f1 in ZEND_DO_FCALL_SPEC_RETVAL_UNUSED_HANDLER /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:2016:4
    #8 0x593a89a in execute_ex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:110228:12
    #9 0x593c988 in zend_execute /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:115646:2
    #10 0x65dd98c in zend_execute_script /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend.c:1975:3
    #11 0x4ea974d in php_execute_script_ex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/main/main.c:2655:13
    #12 0x4eaa9c8 in php_execute_script /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/main/main.c:2695:9
    #13 0x65f0e52 in do_cli /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php_cli.c:947:5
    #14 0x65eb636 in main /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php_cli.c:1368:18
    #15 0x7f23acf4dd8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #16 0x7f23acf4de3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #17 0x6058e4 in _start (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x6058e4)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x606694) in __asan::Allocator::Deallocate(void*, unsigned long, unsigned long, __sanitizer::BufferedStackTrace*, __asan::AllocType)
==2361207==ABORTING

Warning: include(/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/utils.inc): Failed to open stream: No such file or directory in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/10acb0c5.php on line 4

Warning: include(): Failed opening '/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/utils.inc' for inclusion (include_path='.:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps') in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/10acb0c5.php on line 4
bool(true)
bool(true)
bool(true)
bool(true)
bool(true)
bool(true)
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php -d disable_functions=pcntl_fork,pcntl_exec,pcntl_alarm,pcntl_wait,pcntl_waitpid,pcntl_signal,pcntl_wexitstatus,pcntl_wifexited,pcntl_wifsignaled,posix_kill,posix_mkfifo,posix_setuid,posix_setgid,posix_setsid,system,exec,shell_exec,passthru,proc_open,popen,chmod,chown,chgrp,chdir,chroot,mkdir,rmdir,rename,unlink,link,symlink,copy,fsockopen,pfsockopen -d open_basedir="/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d allow_url_fopen=0 -d allow_url_include=0 -d include_path=".:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d error_reporting=E_ALL "$SCRIPT_DIR/test.php"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `0d41f2a7` | Project seed (`setComment`) |
| `b` | `da454dca` | Project seed (`Lazy objects: skipLazyInitialization() preserves readonly semantics`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
