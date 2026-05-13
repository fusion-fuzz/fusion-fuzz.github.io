# SoapClient typemap property breaks engine assumptions

**Issue:** [https://github.com/php/php-src/issues/21421](https://github.com/php/php-src/issues/21421) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-03-12T08:02:12Z`

**Labels:** `Bug`, `Extension: soap`, `Status: Verified`

## Description

### Description

The following code:

```php
<?php
class TestSoapClient extends SoapClient{
}
$options=Array(
'uri'      => 'http://schemas.nothing.com',
'location' => 'test://',
'typemap'  => array(array("type_ns"   => "http://schemas.nothing.com",
"type_name" => "book",
"from_xml"  => "book_from_xml"))
);
$client = new TestSoapClient(NULL, $options);
$p4_obj = (object)(array)$client;
$p4_ser    = serialize($p4_obj);
$p4_deser  = unserialize($p4_ser);
var_dump($p4_deser == $p4_obj);
```

Resulted in this output:
```
php: /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_operators.c:2452: int zend_compare(zval *, zval *): Assertion `0' failed.
Aborted (core dumped)
```

To reproduce:
```
./php-src/sapi/cli/php  ./test.php
```

Commit:
```
13b83a46cfb810418ed15be89f24d45de884c082
```

Configurations:
```
CC="clang-12" CXX="clang++-12" CFLAGS="-DZEND_VERIFY_TYPE_INFERENCE" CXXFLAGS="-DZEND_VERIFY_TYPE_INFERENCE" ./configure --enable-debug --enable-address-sanitizer --enable-undefined-sanitizer --enable-re2c-cgoto --enable-fpm --enable-litespeed --enable-phpdbg-debug --enable-zts --enable-bcmath --enable-calendar --enable-dba --enable-dl-test --enable-exif --enable-ftp --enable-gd --enable-gd-jis-conv --enable-mbstring --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvmsg --enable-zend-test --with-zlib --with-bz2 --with-curl --with-enchant --with-gettext --with-gmp --with-mhash --with-ldap --with-libedit --with-readline --with-snmp --with-sodium --with-xsl --with-zip --with-mysqli --with-pdo-mysql --with-pdo-pgsql --with-pgsql --with-sqlite3 --with-pdo-sqlite --with-webp --with-jpeg --with-freetype --enable-sigchild --with-readline --with-pcre-jit --with-iconv
```

Operating System:
```
Ubuntu 20.04 Host, Docker 0599jiangyc/flowfusion:latest
```

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
