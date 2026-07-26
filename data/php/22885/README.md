*Fusion-Fuzz Bug Report*

**ID:** `c56a8915` &nbsp;·&nbsp; **Signature:** `SUMMARY: AddressSanitizer: global-buffer-overflow (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x61c055) in MemcmpInterceptorCommon(void*, int (*)(void const*, void const*, unsigned long), void const*, void const*, unsigned long)` &nbsp;·&nbsp; **RC:** `1`

The following code:

```php
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
```

Resulted in this output:

```
=================================================================
==2168622==ERROR: AddressSanitizer: global-buffer-overflow on address 0x000009800036 at pc 0x00000061c056 bp 0x7ffe7b996ff0 sp 0x7ffe7b996798
READ of size 10 at 0x000009800036 thread T0
    #0 0x61c055 in MemcmpInterceptorCommon(void*, int (*)(void const*, void const*, unsigned long), void const*, void const*, unsigned long) (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x61c055)
    #1 0x61c54a in memcmp (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x61c54a)
    #2 0x7fabe3c7c09e in zip_file_set_comment (/lib/x86_64-linux-gnu/libzip.so.4+0x709e)
    #3 0x48e650e in php_zip_set_file_comment /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/zip/php_zip.c:78:9
    #4 0x48e729b in zim_ZipArchive_setCommentIndex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/zip/php_zip.c:2248:2
    #5 0x5d047c1 in ZEND_DO_FCALL_SPEC_RETVAL_USED_HANDLER /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:2152:4
    #6 0x5abdaba in execute_ex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:110493:12
    #7 0x5abfba8 in zend_execute /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:115931:2
    #8 0x66eb2dc in zend_execute_script /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend.c:1977:3
    #9 0x5024f1d in php_execute_script_ex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/main/main.c:2631:13
    #10 0x5026198 in php_execute_script /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/main/main.c:2671:9
    #11 0x66fe7a2 in do_cli /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php_cli.c:947:5
    #12 0x66f8f86 in main /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php_cli.c:1368:18
    #13 0x7fabe3a53d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #14 0x7fabe3a53e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #15 0x605b04 in _start (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x605b04)

Address 0x000009800036 is a wild pointer.
SUMMARY: AddressSanitizer: global-buffer-overflow (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x61c055) in MemcmpInterceptorCommon(void*, int (*)(void const*, void const*, unsigned long), void const*, void const*, unsigned long)
Shadow bytes around the buggy address:
  0x0000812f7fb0: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f7fc0: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f7fd0: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f7fe0: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f7ff0: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
=>0x0000812f8000: f9 f9 f9 f9 f9 f9[f9]f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f8010: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f8020: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f8030: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f8040: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
  0x0000812f8050: f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9 f9
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
==2168622==ABORTING

Warning: include(): Failed to open stream: No such file or directory in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/c56a8915.php on line 6

Warning: include(): Failed opening '/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/utils.inc' for inclusion (include_path='.:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps') in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/c56a8915.php on line 6
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php -d disable_functions=pcntl_fork,pcntl_exec,pcntl_alarm,pcntl_wait,pcntl_waitpid,pcntl_signal,pcntl_wexitstatus,pcntl_wifexited,pcntl_wifsignaled,posix_kill,posix_mkfifo,posix_setuid,posix_setgid,posix_setsid,system,exec,shell_exec,passthru,proc_open,popen,chmod,chown,chgrp,chdir,chroot,mkdir,rmdir,rename,unlink,link,symlink,copy,fsockopen,pfsockopen -d open_basedir="/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d allow_url_fopen=0 -d allow_url_include=0 -d include_path=".:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d opcache.enable=0 "$SCRIPT_DIR/test.php"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `531abb8f` | Bug corpus (project: `inferredbugs-java`, name: `HikariCP/19/file_before.txt`) |
| `b` | `45a76f95` | Project seed (`setComment`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
