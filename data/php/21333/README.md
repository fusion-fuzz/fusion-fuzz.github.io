# ext/phar: Segfault in phar_archive_delref during PharFileInfo destruction for noexist compressed archives

**Issue:** [https://github.com/php/php-src/issues/21333](https://github.com/php/php-src/issues/21333) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-03T16:34:07Z`

**Labels:** `Bug`, `Extension: phar`, `Status: Verified`

## Description

### Description

The following code:

```php
<?php
$phar_path = __DIR__ . "/noexist.phar";
$gz_path = $phar_path . ".gz";

// 1. Create a base Phar with mixed entry types
$phar = new Phar($phar_path);
$phar->addFromString("file", "initial_content");
$phar->addEmptyDir("dir");

// 2. Create the compressed version (the crash target)
$phar2 = $phar->compress(Phar::GZ);

// 3. Create a dummy file to use for copy operations
$tmp_src = __DIR__ . "/source.tmp";
file_put_contents($tmp_src, str_repeat("A", 100));

// 4. Iterate and modify.
// The combination of using the PharFileInfo object ($item)
// as a path for copy/unlink while the Phar is compressed is key.
foreach ($phar2 as $item) {
// This triggers string casting of PharFileInfo
// and internal metadata lookups in the compressed archive.
@copy($tmp_src, $item);

// Unlinking entries in a compressed phar while iterating
// often leads to refcount mismatches.
@unlink($item);
}

// 5. Keep variables in scope until the very end.
// The crash occurs during the engine's shutdown destructors.
$garbage = get_defined_vars();

echo "Done\n";
?>
```

Resulted in this output:
```
AddressSanitizer:DEADLYSIGNAL
=================================================================
==2165222==ERROR: AddressSanitizer: SEGV on unknown address 0x00000000812c (pc 0x0000033a035d bp 0x7ffed3dc8f50 sp 0x7ffed3dc8c60 T0)
==2165222==The signal is caused by a READ memory access.
    #0 0x33a035d in phar_archive_delref /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/ext/phar/phar.c:248:12
    #1 0x335a9ea in zim_PharFileInfo___destruct /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/ext/phar/phar_object.c:4492:3
    #2 0x58c31ac in zend_call_function /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_execute_API.c:1019:4
    #3 0x58c8c2e in zend_call_known_function /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_execute_API.c:1100:23
    #4 0x64de684 in zend_call_known_instance_method /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_API.h:860:2
    #5 0x64d6f1b in zend_call_known_instance_method_with_0_params /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_API.h:866:2
    #6 0x64d5570 in zend_objects_destroy_object /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_objects.c:172:3
    #7 0x3c9fe04 in spl_filesystem_object_destroy_object /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/ext/spl/spl_directory.c:109:2
    #8 0x64cd65a in zend_objects_store_del /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_objects_API.c:181:4
    #9 0x65e4c67 in rc_dtor_func /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_variables.c:57:2
    #10 0x5fb9192 in zend_assign_to_variable /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_execute.h:183:4
    #11 0x5ff71ac in zend_fe_fetch_object_helper_SPEC /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_vm_execute.h:3107:3
    #12 0x5c2519e in ZEND_FE_FETCH_R_SPEC_TMP_HANDLER /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_vm_execute.h:17724:3
    #13 0x2968414 in zend_jit_trace_counter_helper /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/ext/opcache/jit/zend_jit_vm_helpers.c:495:3
    #14 0x296970a in zend_jit_loop_trace_helper /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/ext/opcache/jit/zend_jit_vm_helpers.c:532:2
    #15 0x59324eb in execute_ex /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_vm_execute.h:110065:12
    #16 0x5934a7c in zend_execute /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend_vm_execute.h:115483:2
    #17 0x6640859 in zend_execute_script /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/Zend/zend.c:1979:3
    #18 0x4e7b78a in php_execute_script_ex /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/main/main.c:2648:13
    #19 0x4e7c8c8 in php_execute_script /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/main/main.c:2688:9
    #20 0x665576a in do_cli /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/sapi/cli/php_cli.c:949:5
    #21 0x664fb4f in main /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/sapi/cli/php_cli.c:1360:18
    #22 0x7f8acb0e1d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #23 0x7f8acb0e1e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #24 0x606254 in _start (/home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/sapi/cli/php+0x606254)

AddressSanitizer can not provide additional info.
SUMMARY: AddressSanitizer: SEGV /home/phpfuzz/WorkSpace/FusionFuzzLoop/projects/php/php-src/ext/phar/phar.c:248:12 in phar_archive_delref
==2165222==ABORTING
```

To reproduce:
```
./php-src/sapi/cli/php -d "phar.readonly=0" ./test.php
```

Commit:
```
ffd58ea601c1cdbf95e4a8e35c07841bf8395d13
```

Configurations:
```
CC="clang-12" CXX="clang++-12" CFLAGS="-DZEND_VERIFY_TYPE_INFERENCE" CXXFLAGS="-DZEND_VERIFY_TYPE_INFERENCE" ./configure --enable-debug --enable-address-sanitizer --enable-undefined-sanitizer --enable-re2c-cgoto --enable-fpm --enable-litespeed --enable-phpdbg-debug --enable-zts --enable-bcmath --enable-calendar --enable-dba --enable-dl-test --enable-exif --enable-ftp --enable-gd --enable-gd-jis-conv --enable-mbstring --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-zend-test --with-zlib --with-bz2 --with-curl --with-enchant --with-gettext --with-gmp --with-mhash --with-ldap --with-libedit --with-readline --with-snmp --with-sodium --with-xsl --with-zip --with-mysqli --with-pdo-mysql --with-pdo-pgsql --with-pgsql --with-sqlite3 --with-pdo-sqlite --with-webp --with-jpeg --with-freetype --enable-sigchild --with-readline --with-pcre-jit --with-iconv
```

Operating System:
```
Ubuntu 20.04 Host, Docker 0599jiangyc/flowfusion:latest
```

*This report is automatically generated by [FlowFusion](https://github.com/php/flowfusion)*

### PHP Version

```plain
nightly
```

### Operating System

_No response_

---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
