*Fusion-Fuzz Bug Report*

**ID:** `7b0d6acb` &nbsp;·&nbsp; **Signature:** `SUMMARY: AddressSanitizer: heap-use-after-free /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/dom/node.c:500:17 in dom_node_namespace_uri_read` &nbsp;·&nbsp; **RC:** `1`

The following code:

```php
<?php
try {
try { $cls = new Dom\Attr(); } catch (\Throwable $_e) { $cls = new stdClass(); }
try { $clsAttr=$cls->nodeValue; } catch (\Throwable $_e) {}
$ROWS = 5;
$COLS = 3;
$rowCount = 0;
$dom1 = Dom\HTMLDocument::createEmpty();
$attribute1 = $dom1->createAttribute("my-attribute");
$container = $dom1->appendChild($dom1->createElement("container"));
$attribute2 = $dom1->createAttribute("my-attribute");
$attribute4 = $dom1->createAttributeNS("urn:a", "my-attribute");
$attribute3 = $dom1->createAttributeNS("", "my-ATTRIBUTE");
$rs = [
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6'],
    ['One' => '4', 'two' => '5', 'THREE' => '6']
];
$attribute1->value = "1";
$attribute3->value = "3";
$attribute4->value = "4";
$attribute2->value = "2";
echo "--- With namespace ---\n";
echo "--- Resulting document ---\n";
class TestBean {
    public $one;
    public $two;
    public $three;
    public $doNotSet = 'not set';
    public $intTest = 3;
    public $integerTest = 4;
    public $nullObjectTest = null;
    public $nullPrimitiveTest = 0;
    public $notDate = 'Sun Mar 14 15:19:15 MST 2004';
    public function getOne() {
        return $this->one;
    }
    public function getTwo() {
        return $this->two;
    }
    public function getThree() {
        return $this->three;
    }
    public function getDoNotSet() {
        return $this->doNotSet;
    }
    public function getIntTest() {
        return $this->intTest;
    }
    public function getIntegerTest() {
        return $this->integerTest;
    }
    public function getNullObjectTest() {
        return $this->nullObjectTest;
    }
    public function getNullPrimitiveTest() {
        return $this->nullPrimitiveTest;
    }
    public function getNotDate() {
        return $this->notDate;
    }
}
echo $dom1->saveHtml(), "\n";
$container->setAttributeNode($attribute1);
$container->setAttributeNode($attribute4);
echo "--- Without namespace ---\n";
var_dump($container->setAttributeNode($attribute2) === $attribute1);
var_dump($container->setAttributeNode($attribute1) === null);
var_dump($container->setAttributeNode($attribute3) === null);
$attribute5 = $dom1->createAttributeNS("urn:b", "my-attribute");
var_dump($container->setAttributeNode($attribute4) === null);
$attribute5->value = "5";
var_dump($container->setAttributeNodeNS($attribute5) === null);
class BasicRowProcessor {
    public function toArray($result) {
        return [$result['One'], $result['two'], $result['THREE']];
    }
    public function toBean($result, $class) {
        $bean = new $class();
        foreach ($result as $key => $value) {
            $bean->{strtolower($key)} = $value;
        }
        return $bean;
    }
    public function toBeanList($resultSet, $class) {
        $list = [];
        foreach ($resultSet as $result) {
            $list[] = $this->toBean($result, $class);
        }
        return $list;
    }
    public function toMap($result) {
        return array_change_key_case($result);
    }
}
$processor = new BasicRowProcessor();
$a = null;
foreach ($rs as $result) {
    $a = $processor->toArray($result);
    $rowCount++;
}
$b = null;
foreach ($rs as $result) {
    $b = $processor->toBean($result, TestBean::class);
}
$list = $processor->toBeanList($rs, TestBean::class);
$m = null;
foreach ($rs as $result) {
    $m = $processor->toMap($result);
    $rowCount++;
}
var_dump(get_defined_vars());
try { $cls->isEqualNode($attribute3); } catch (\Throwable $e) {};
try { $cls->isEqualNode($attribute1); } catch (\Throwable $e) {};
try { $cls->isEqualNode($attribute3); } catch (\Throwable $e) {};
try { $cls->isEqualNode($dom1); } catch (\Throwable $e) {};
try { $cls->isEqualNode($dom1); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
```

Resulted in this output:

```
=================================================================
==2631458==ERROR: AddressSanitizer: heap-use-after-free on address 0x608000007128 at pc 0x00000107fea2 bp 0x7ffdcb5e78c0 sp 0x7ffdcb5e78b8
READ of size 4 at 0x608000007128 thread T0
    #0 0x107fea1 in dom_node_namespace_uri_read /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/dom/node.c:500:17
    #1 0x114907f in dom_get_debug_info_helper /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/dom/php_dom.c:528:7
    #2 0x10f12fc in dom_get_debug_info /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/dom/php_dom.c:551:9
    #3 0x65398ba in zend_std_get_properties_for /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_object_handlers.c:2612:10
    #4 0x653a5d1 in zend_get_properties_for /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_object_handlers.c:2661:9
    #5 0x445d8f9 in php_var_dump /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/standard/var.c:182:11
    #6 0x445fe0e in php_array_element_dump /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/standard/var.c:49:2
    #7 0x445c576 in php_var_dump /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/standard/var.c:156:5
    #8 0x446225a in zif_var_dump /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/standard/var.c:253:3
    #9 0x5e2b59e in ZEND_DO_ICALL_SPEC_RETVAL_UNUSED_HANDLER /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:1322:2
    #10 0x59bbfcb in execute_ex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:110228:12
    #11 0x59be4f3 in zend_execute /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_vm_execute.h:115646:2
    #12 0x66b1389 in zend_execute_script /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend.c:1972:3
    #13 0x4f0ce8a in php_execute_script_ex /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/main/main.c:2655:13
    #14 0x4f0e3c8 in php_execute_script /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/main/main.c:2695:9
    #15 0x66c5359 in do_cli /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php_cli.c:947:5
    #16 0x66bf82f in main /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php_cli.c:1370:18
    #17 0x7fbb76c81d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #18 0x7fbb76c81e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #19 0x6058e4 in _start (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x6058e4)

0x608000007128 is located 8 bytes inside of 96-byte region [0x608000007120,0x608000007180)
freed by thread T0 here:
    #0 0x680542 in free (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x680542)
    #1 0x7fbb7759efc3 in xmlAddChild (/lib/x86_64-linux-gnu/libxml2.so.2+0x65fc3)

previously allocated by thread T0 here:
    #0 0x6807ad in malloc (/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php+0x6807ad)
    #1 0x7fbb775a12ae in xmlNewDocProp (/lib/x86_64-linux-gnu/libxml2.so.2+0x682ae)

SUMMARY: AddressSanitizer: heap-use-after-free /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/ext/dom/node.c:500:17 in dom_node_namespace_uri_read
Shadow bytes around the buggy address:
  0x0c107fff8dd0: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 fa
  0x0c107fff8de0: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 fa
  0x0c107fff8df0: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 fa
  0x0c107fff8e00: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 fa
  0x0c107fff8e10: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 00
=>0x0c107fff8e20: fa fa fa fa fd[fd]fd fd fd fd fd fd fd fd fd fd
  0x0c107fff8e30: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c107fff8e40: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c107fff8e50: fa fa fa fa 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c107fff8e60: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c107fff8e70: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==2631458==ABORTING

Warning: Undefined property: stdClass::$nodeValue in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php on line 4
--- With namespace ---
--- Resulting document ---
<container></container>
--- Without namespace ---
bool(true)
bool(false)
bool(true)
bool(true)
bool(true)
array(27) {
  ["argv"]=>
  array(1) {
    [0]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
  }
  ["argc"]=>
  int(1)
  ["_GET"]=>
  array(0) {
  }
  ["_POST"]=>
  array(0) {
  }
  ["_COOKIE"]=>
  array(0) {
  }
  ["_FILES"]=>
  array(0) {
  }
  ["_SERVER"]=>
  array(26) {
    ["LESSOPEN"]=>
    string(22) "| /usr/bin/lesspipe %s"
    ["TMUX"]=>
    string(27) "/tmp/tmux-1000/default,30,0"
    ["HOSTNAME"]=>
    string(12) "fbf3e9e82c56"
    ["SHLVL"]=>
    string(1) "2"
    ["HOME"]=>
    string(10) "/home/fuzz"
    ["OLDPWD"]=>
    string(20) "/home/fuzz/WorkSpace"
    ["TERM_PROGRAM_VERSION"]=>
    string(4) "3.2a"
    ["LC_CTYPE"]=>
    string(7) "C.UTF-8"
    ["_"]=>
    string(16) "/usr/bin/python3"
    ["TERM"]=>
    string(6) "screen"
    ["PATH"]=>
    string(60) "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ["LS_COLORS"]=>
    string(1508) "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"
    ["TERM_PROGRAM"]=>
    string(4) "tmux"
    ["SHELL"]=>
    string(7) "/bin/sh"
    ["LESSCLOSE"]=>
    string(23) "/usr/bin/lesspipe %s %s"
    ["PWD"]=>
    string(55) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared"
    ["TMUX_PANE"]=>
    string(2) "%0"
    ["PHP_SELF"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
    ["SCRIPT_NAME"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
    ["SCRIPT_FILENAME"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
    ["PATH_TRANSLATED"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
    ["DOCUMENT_ROOT"]=>
    string(0) ""
    ["REQUEST_TIME_FLOAT"]=>
    float(1782372927.213332)
    ["REQUEST_TIME"]=>
    int(1782372927)
    ["argv"]=>
    array(1) {
      [0]=>
      string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
    }
    ["argc"]=>
    int(1)
  }
  ["cls"]=>
  object(stdClass)#1 (0) {
  }
  ["_e"]=>
  object(Error)#2 (7) {
    ["message":protected]=>
    string(57) "Call to private Dom\Node::__construct() from global scope"
    ["string":"Error":private]=>
    string(0) ""
    ["code":protected]=>
    int(0)
    ["file":protected]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/7b0d6acb.php"
    ["line":protected]=>
    int(3)
    ["trace":"Error":private]=>
    array(0) {
    }
    ["previous":"Error":private]=>
    NULL
  }
  ["clsAttr"]=>
  NULL
  ["ROWS"]=>
  int(5)
  ["COLS"]=>
  int(3)
  ["rowCount"]=>
  int(10)
  ["dom1"]=>
  object(Dom\HTMLDocument)#3 (29) {
    ["implementation"]=>
    string(22) "(object value omitted)"
    ["URL"]=>
    string(11) "about:blank"
    ["documentURI"]=>
    string(11) "about:blank"
    ["characterSet"]=>
    string(5) "UTF-8"
    ["charset"]=>
    string(5) "UTF-8"
    ["inputEncoding"]=>
    string(5) "UTF-8"
    ["doctype"]=>
    NULL
    ["documentElement"]=>
    string(22) "(object value omitted)"
    ["children"]=>
    string(22) "(object value omitted)"
    ["firstElementChild"]=>
    string(22) "(object value omitted)"
    ["lastElementChild"]=>
    string(22) "(object value omitted)"
    ["childElementCount"]=>
    int(1)
    ["body"]=>
    NULL
    ["head"]=>
    NULL
    ["title"]=>
    string(0) ""
    ["nodeType"]=>
    int(13)
    ["nodeName"]=>
    string(9) "#document"
    ["baseURI"]=>
    string(11) "about:blank"
    ["isConnected"]=>
    bool(true)
    ["ownerDocument"]=>
    NULL
    ["parentNode"]=>
    NULL
    ["parentElement"]=>
    NULL
    ["childNodes"]=>
    string(22) "(object value omitted)"
    ["firstChild"]=>
    string(22) "(object value omitted)"
    ["lastChild"]=>
    string(22) "(object value omitted)"
    ["previousSibling"]=>
    NULL
    ["nextSibling"]=>
    NULL
    ["nodeValue"]=>
    NULL
    ["textContent"]=>
    NULL
  }
  ["attribute1"]=>
  object(Dom\Attr)#4 (21) {
    ["namespaceURI"]=>
    NULL
    ["prefix"]=>
    NULL
    ["localName"]=>
    string(12) "my-attribute"
    ["name"]=>
    string(12) "my-attribute"
    ["value"]=>
    string(1) "1"
    ["ownerElement"]=>
    string(22) "(object value omitted)"
    ["specified"]=>
    bool(true)
    ["nodeType"]=>
    int(2)
    ["nodeName"]=>
    string(12) "my-attribute"
    ["baseURI"]=>
    string(11) "about:blank"
    ["isConnected"]=>
    bool(true)
    ["ownerDocument"]=>
    string(22) "(object value omitted)"
    ["parentNode"]=>
    string(22) "(object value omitted)"
    ["parentElement"]=>
    string(22) "(object value omitted)"
    ["childNodes"]=>
    string(22) "(object value omitted)"
    ["firstChild"]=>
    string(22) "(object value omitted)"
    ["lastChild"]=>
    string(22) "(object value omitted)"
    ["previousSibling"]=>
    NULL
    ["nextSibling"]=>
    string(22) "(object value omitted)"
    ["nodeValue"]=>
    string(1) "1"
    ["textContent"]=>
    string(1) "1"
  }
  ["container"]=>
  object(Dom\HTMLElement)#5 (31) {
    ["namespaceURI"]=>
    string(28) "http://www.w3.org/1999/xhtml"
    ["prefix"]=>
    NULL
    ["localName"]=>
    string(9) "container"
    ["tagName"]=>
    string(9) "CONTAINER"
    ["id"]=>
    string(0) ""
    ["className"]=>
    string(0) ""
    ["classList"]=>
    string(22) "(object value omitted)"
    ["attributes"]=>
    string(22) "(object value omitted)"
    ["children"]=>
    string(22) "(object value omitted)"
    ["firstElementChild"]=>
    NULL
    ["lastElementChild"]=>
    NULL
    ["childElementCount"]=>
    int(0)
    ["previousElementSibling"]=>
    NULL
    ["nextElementSibling"]=>
    NULL
    ["innerHTML"]=>
    string(0) ""
    ["outerHTML"]=>
    string(91) "<container my-attribute="1" my-ATTRIBUTE="3" my-attribute="4" my-attribute="5"></container>"
    ["substitutedNodeValue"]=>
    string(0) ""
    ["nodeType"]=>
    int(1)
    ["nodeName"]=>
    string(9) "CONTAINER"
    ["baseURI"]=>
    string(11) "about:blank"
    ["isConnected"]=>
    bool(true)
    ["ownerDocument"]=>
    string(22) "(object value omitted)"
    ["parentNode"]=>
    string(22) "(object value omitted)"
    ["parentElement"]=>
    NULL
    ["childNodes"]=>
    string(22) "(object value omitted)"
    ["firstChild"]=>
    NULL
    ["lastChild"]=>
    NULL
    ["previousSibling"]=>
    NULL
    ["nextSibling"]=>
    NULL
    ["nodeValue"]=>
    NULL
    ["textContent"]=>
    string(0) ""
  }
  ["attribute2"]=>
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php -d disable_functions=pcntl_fork,pcntl_exec,pcntl_alarm,pcntl_wait,pcntl_waitpid,pcntl_signal,pcntl_wexitstatus,pcntl_wifexited,pcntl_wifsignaled,posix_kill,posix_mkfifo,posix_setuid,posix_setgid,posix_setsid,system,exec,shell_exec,passthru,proc_open,popen,chmod,chown,chgrp,chdir,chroot,mkdir,rmdir,rename,unlink,link,symlink,copy,fsockopen,pfsockopen -d open_basedir="/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d allow_url_fopen=0 -d allow_url_include=0 -d include_path=".:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d opcache.enable_cli=1 "$SCRIPT_DIR/test.php"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `971e3b08` | Project seed (`Dom\Element::setAttributeNode(NS) in the same document`) |
| `b` | `e9e1b963` | Bug corpus (project: `inferredbugs-java`, name: `commons-dbutils/1/file_before.txt`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
