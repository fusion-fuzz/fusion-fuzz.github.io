# Memory leak in ZipArchive::addGlob() via php_zip_glob() when glob results are not freed on open_basedir restriction

**Issue:** [https://github.com/php/php-src/issues/21698](https://github.com/php/php-src/issues/21698) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-04-10T00:55:27Z`

**Labels:** `Bug`, `Extension: zip`, `Status: Verified`

## Description

### Description

The following code:

```php
<?php
$zip = new ZipArchive();
$zip->addGlob(__FILE__, 0, []);
```

Resulted in this output:
```

=================================================================
==2222867==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 16 byte(s) in 1 object(s) allocated from:
    #0 0x68170a in reallocarray (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x68170a)
    #1 0x50f4c33 in globextend /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:898:10
    #2 0x50f8012 in glob2 /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:741:11
    #3 0x50f3b62 in glob1 /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:696:9
    #4 0x50edee0 in glob0 /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:630:13
    #5 0x50eb592 in php_glob /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:298:10
    #6 0x492f871 in php_zip_glob /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/zip/php_zip.c:684:18
    #7 0x4945dc8 in php_zip_add_from_pattern /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/zip/php_zip.c:1737:11
    #8 0x4944e01 in zim_ZipArchive_addGlob /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/zip/php_zip.c:1824:2
    #9 0x5d9b96b in ZEND_DO_FCALL_SPEC_RETVAL_UNUSED_HANDLER /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:2000:4
    #10 0x5b468bb in execute_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:110113:12
    #11 0x5b48e4c in zend_execute /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:115531:2
    #12 0x6856d39 in zend_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend.c:1972:3
    #13 0x5092b2a in php_execute_script_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2648:13
    #14 0x5093c68 in php_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2688:9
    #15 0x686bc4a in do_cli /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:949:5
    #16 0x686602f in main /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1360:18
    #17 0x7306b8923d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

Indirect leak of 14 byte(s) in 1 object(s) allocated from:
    #0 0x6810fd in malloc (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x6810fd)
    #1 0x50f66ac in globextend /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:942:14
    #2 0x50f8012 in glob2 /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:741:11
    #3 0x50f3b62 in glob1 /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:696:9
    #4 0x50edee0 in glob0 /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:630:13
    #5 0x50eb592 in php_glob /home/phpfuzz/WorkSpace/flowfusion/php-src/main/php_glob.c:298:10
    #6 0x492f871 in php_zip_glob /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/zip/php_zip.c:684:18
    #7 0x4945dc8 in php_zip_add_from_pattern /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/zip/php_zip.c:1737:11
    #8 0x4944e01 in zim_ZipArchive_addGlob /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/zip/php_zip.c:1824:2
    #9 0x5d9b96b in ZEND_DO_FCALL_SPEC_RETVAL_UNUSED_HANDLER /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:2000:4
    #10 0x5b468bb in execute_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:110113:12
    #11 0x5b48e4c in zend_execute /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:115531:2
    #12 0x6856d39 in zend_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend.c:1972:3
    #13 0x5092b2a in php_execute_script_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2648:13
    #14 0x5093c68 in php_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2688:9
    #15 0x686bc4a in do_cli /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:949:5
    #16 0x686602f in main /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1360:18
    #17 0x7306b8923d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

SUMMARY: AddressSanitizer: 30 byte(s) leaked in 2 allocation(s).
```

To reproduce:
```
./php-src/sapi/cli/php -d "open_basedir=/usr/local" -d "opcache.jit=1205" -d "opcache.enable=1" -d "opcache.enable_cli=1" -d "opcache.jit=1254" ./test.php
```

Commit:
```
cdc0366bbb366934e91b5461d524226ecb26c891
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
