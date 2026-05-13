# heap-buffer-overflow mail.c

**Issue:** [https://github.com/php/php-src/issues/20257](https://github.com/php/php-src/issues/20257) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-22T03:23:01Z`

**Labels:** `Bug`, `Extension: standard`, `Status: Verified`

## Description

### Description

The following code:

```php
<?php
var_dump( mail($to, $subject, $message) );
```

Resulted in this output:
```
=================================================================
==355357==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x6030000019e0 at pc 0x0000043684c7 bp 0x7ffdc5308cf0 sp 0x7ffdc5308ce8
READ of size 1 at 0x6030000019e0 thread T0
    #0 0x43684c6 in php_mail /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/standard/mail.c:618:9
    #1 0x4365934 in zif_mail /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/standard/mail.c:352:6
    #2 0x604848f in ZEND_DO_ICALL_SPEC_RETVAL_USED_HANDLER /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:1421:2
    #3 0x5b62a3b in execute_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:115764:12
    #4 0x5b64fcc in zend_execute /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:121476:2
    #5 0x68ebc29 in zend_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend.c:1977:3
    #6 0x50c283a in php_execute_script_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2640:13
    #7 0x50c3978 in php_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2680:9
    #8 0x6900b3a in do_cli /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:951:5
    #9 0x68faf1f in main /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1362:18
    #10 0x727d7ccfcd8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #11 0x727d7ccfce3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #12 0x606204 in _start (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x606204)

0x6030000019e0 is located 0 bytes to the right of 32-byte region [0x6030000019c0,0x6030000019e0)
allocated by thread T0 here:
    #0 0x6810cd in malloc (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x6810cd)
    #1 0x5738733 in __zend_malloc /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_alloc.c:3543:14
    #2 0x686501c in zend_string_alloc /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_string.h:167:36
    #3 0x686711a in zend_string_init /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_string.h:189:21
    #4 0x68638a3 in zend_string_init_interned_permanent /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_string.c:278:8
    #5 0x6861663 in zend_interned_strings_init /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_string.c:104:22
    #6 0x68d05fc in zend_startup /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend.c:1056:2
    #7 0x50b2cb8 in php_module_startup /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2248:2
    #8 0x6906808 in php_cli_startup /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:397:9
    #9 0x68fa739 in main /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1329:6
    #10 0x727d7ccfcd8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16

SUMMARY: AddressSanitizer: heap-buffer-overflow /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/standard/mail.c:618:9 in php_mail
Shadow bytes around the buggy address:
  0x0c067fff82e0: 00 04 fa fa 00 00 00 01 fa fa 00 00 02 fa fa fa
  0x0c067fff82f0: 00 00 00 05 fa fa 00 00 01 fa fa fa 00 00 05 fa
  0x0c067fff8300: fa fa 00 00 00 04 fa fa 00 00 03 fa fa fa 00 00
  0x0c067fff8310: 06 fa fa fa fd fd fd fd fa fa fd fd fd fd fa fa
  0x0c067fff8320: 00 00 00 00 fa fa fd fd fd fa fa fa fd fd fd fd
=>0x0c067fff8330: fa fa 00 00 00 07 fa fa 00 00 00 00[fa]fa 00 00
  0x0c067fff8340: 00 00 fa fa 00 00 00 00 fa fa 00 00 00 00 fa fa
  0x0c067fff8350: 00 00 00 00 fa fa 00 00 00 00 fa fa 00 00 00 00
  0x0c067fff8360: fa fa 00 00 00 00 fa fa 00 00 00 00 fa fa 00 00
  0x0c067fff8370: 00 00 fa fa 00 00 00 00 fa fa 00 00 00 00 fa fa
  0x0c067fff8380: 00 00 00 00 fa fa 00 00 00 00 fa fa 00 00 00 00
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
==355357==ABORTING
```

To reproduce:
```
./php-src/sapi/cli/php  -d "mail.cr_lf_mode=lf" ./test.php
```

Commit:
```
02d187d7663afdde5027f72fad180079806c4fc9
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
