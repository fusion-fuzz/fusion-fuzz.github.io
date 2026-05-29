*Fusion-Fuzz Bug Report*

**ID:** `a3ef0eae` &nbsp;·&nbsp; **Signature:** `Assertion:(call->func->common.fn_flags & (1 << 12)) ? (zval_get_type(&(*(ret))) == 10) : !(zval_get_type(&(*(ret))) == 10)` &nbsp;·&nbsp; **RC:** `134`

The following code:

```php
<?php
try {
error_reporting(E_ALL);
class foo {
    public $x = array(1);
    public function &b() {
        return $this->x;
    }
}
$foo = new foo;
$a = 'b';
var_dump($foo->$a()[0]);
$h = &$foo->$a();
$h[] = 2;
var_dump($foo->$a());
function findNthMostRepeatedElement(array $numbers, int $position): int {
    validateInput($numbers, $position);
    $result = null;
    $counter = [];
    foreach ($numbers as $i) {
        if (!isset($counter[$i])) {
            $counter[$i] = 1;
        } else {
            $counter[$i]++;
        }
    }
    foreach ($counter as $candidate => $count) {
        if ($count === $position) {
            $result = $candidate;
            break;
        }
    }
    validateResult($result);
    return $result;
}
function validateInput(array $numbers, int $position): void {
    if (count($numbers) === 0 || $position <= 0) {
        throw new InvalidArgumentException("You can't pass empty arrays or position values less than 1 as parameter.");
    }
}
function validateResult(?int $result): void {
    if ($result === null) {
        throw new InvalidArgumentException("There are no elements repeated n times in the array passed as argument");
    }
}
$numbers = [1, 2, 2, 3, 3, 3, 4];
$position = 2;
$result = findNthMostRepeatedElement($numbers, $position);
echo $result;
var_dump(get_defined_vars());
try { zend_call_method_if_exists($h,$x,$fusion); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($foo,$a,$a); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($fusion,$x,$a); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($fusion,$a,$x); } catch (\Throwable $e) {};
try { zend_call_method_if_exists($a,$foo,$fusion); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
```

Resulted in this output:

```
php: Zend/zend_vm_execute.h:1334: const zend_op *ZEND_DO_ICALL_SPEC_RETVAL_UNUSED_HANDLER(zend_execute_data *, const zend_op *): Assertion `(call->func->common.fn_flags & (1 << 12)) ? (zval_get_type(&(*(ret))) == 10) : !(zval_get_type(&(*(ret))) == 10)' failed.
Aborted (core dumped)
int(1)
array(2) {
  [0]=>
  int(1)
  [1]=>
  int(2)
}
2array(13) {
  ["argv"]=>
  array(1) {
    [0]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php"
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
    string(27) "/tmp/tmux-1000/default,31,0"
    ["HOSTNAME"]=>
    string(12) "9ed0f369a397"
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
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php"
    ["SCRIPT_NAME"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php"
    ["SCRIPT_FILENAME"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php"
    ["PATH_TRANSLATED"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php"
    ["DOCUMENT_ROOT"]=>
    string(0) ""
    ["REQUEST_TIME_FLOAT"]=>
    float(1779803226.926147)
    ["REQUEST_TIME"]=>
    int(1779803226)
    ["argv"]=>
    array(1) {
      [0]=>
      string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php"
    }
    ["argc"]=>
    int(1)
  }
  ["foo"]=>
  object(foo)#1 (1) {
    ["x"]=>
    &array(2) {
      [0]=>
      int(1)
      [1]=>
      int(2)
    }
  }
  ["a"]=>
  string(1) "b"
  ["h"]=>
  &array(2) {
    [0]=>
    int(1)
    [1]=>
    int(2)
  }
  ["numbers"]=>
  array(7) {
    [0]=>
    int(1)
    [1]=>
    int(2)
    [2]=>
    int(2)
    [3]=>
    int(3)
    [4]=>
    int(3)
    [5]=>
    int(3)
    [6]=>
    int(4)
  }
  ["position"]=>
  int(2)
  ["result"]=>
  int(2)
}

Warning: Undefined variable $x in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php on line 51

Warning: Undefined variable $fusion in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/a3ef0eae.php on line 51
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
| `a` | `34c83049` | Project seed (`Testing array dereference with dynamic method name and references`) |
| `b` | `e95a182d` | Bug corpus (project: `inferredbugs-java`, name: `Algorithms/1/file_before.txt`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
