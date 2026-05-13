# UAF Dom dom_objects_free_storage

**Issue:** [https://github.com/php/php-src/issues/21496](https://github.com/php/php-src/issues/21496) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-23T04:41:35Z`

**Labels:** `Bug`, `Extension: xsl`, `Status: Verified`

## Description

### Description

The following code:

```php
<?php
$comment = new DOMComment("my value");
$doc = new DOMDocument();
$doc->loadXML(<<<XML
<container/>
XML);
$doc->documentElement->appendChild($comment);
$fusion = $comment;
include __DIR__ .'/prepare.inc';
$proc->importStylesheet($fusion);
```

Resulted in this output:
```
=================================================================
==3155==ERROR: AddressSanitizer: heap-use-after-free on address 0x60c00000c948 at pc 0x0000010ff0d2 bp 0x7ffc2f580080 sp 0x7ffc2f580078
READ of size 4 at 0x60c00000c948 thread T0
    #0 0x10ff0d1 in dom_objects_free_storage /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/dom/php_dom.c:1486:13
    #1 0x66d1611 in zend_objects_store_del /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_objects_API.c:196:4
    #2 0x67e7c97 in rc_dtor_func /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_variables.c:57:2
    #3 0x67e7f1e in i_zval_ptr_dtor /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_variables.h:45:4
    #4 0x67e7cd4 in zval_ptr_dtor /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_variables.c:84:2
    #5 0x6304051 in _zend_hash_del_el_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_hash.c:1500:3
    #6 0x63017cd in _zend_hash_del_el /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_hash.c:1527:2
    #7 0x6316b66 in zend_hash_graceful_reverse_destroy /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_hash.c:2052:4
    #8 0x5aa22e5 in zend_shutdown_executor_values /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_execute_API.c:283:3
    #9 0x5aae20e in shutdown_executor /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_execute_API.c:454:2
    #10 0x6830d9b in zend_deactivate /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend.c:1355:2
    #11 0x506c84a in php_request_shutdown /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2028:2
    #12 0x685dba1 in do_cli /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1156:3
    #13 0x6852b7f in main /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1360:18
    #14 0x7fa824709d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #15 0x7fa824709e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #16 0x606244 in _start (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x606244)

0x60c00000c948 is located 8 bytes inside of 120-byte region [0x60c00000c940,0x60c00000c9b8)
freed by thread T0 here:
    #0 0x680ea2 in free (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x680ea2)
    #1 0x7fa8249757fa in xsltParseStylesheetProcess (/lib/x86_64-linux-gnu/libxslt.so.1+0x137fa)

previously allocated by thread T0 here:
    #0 0x68110d in malloc (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x68110d)
    #1 0x7fa825166b9b in xmlNewComment (/lib/x86_64-linux-gnu/libxml2.so.2+0x63b9b)

SUMMARY: AddressSanitizer: heap-use-after-free /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/dom/php_dom.c:1486:13 in dom_objects_free_storage
Shadow bytes around the buggy address:
  0x0c187fff98d0: 00 00 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c187fff98e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c187fff98f0: fa fa fa fa fa fa fa fa 00 00 00 00 00 00 00 00
  0x0c187fff9900: 00 00 00 00 00 00 00 00 fa fa fa fa fa fa fa fa
  0x0c187fff9910: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x0c187fff9920: fa fa fa fa fa fa fa fa fd[fd]fd fd fd fd fd fd
  0x0c187fff9930: fd fd fd fd fd fd fd fa fa fa fa fa fa fa fa fa
  0x0c187fff9940: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 fa
  0x0c187fff9950: fa fa fa fa fa fa fa fa fd fd fd fd fd fd fd fd
  0x0c187fff9960: fd fd fd fd fd fd fd fa fa fa fa fa fa fa fa fa
  0x0c187fff9970: fd fd fd fd fd fd fd fd fd fd fd fd fd fd fd fa
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
==3155==ABORTING
```

To reproduce:
```
./php-src/sapi/cli/php  ./test.php
```

Commit:
```
f102735d7139858cd1fe2a80a27f361e410ae887
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

Need ext/xsl/tests/prepare.inc

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
