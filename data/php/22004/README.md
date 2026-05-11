*Fusion-Fuzz Bug Report*

**ID:** `3534aec2` &nbsp;·&nbsp; **Signature:** `Assertion:info & (1 << type)` &nbsp;·&nbsp; **RC:** `134`

The following code:

```php
<?php
try {
function printable($s) {
    $result = '';
    for ($i = 0; $i < strlen($s); $i++) {
        $ch = $s[$i];
        if (ord($ch) <= 32 || ord($ch) >= 128) {
            $result .= '(' . ord($ch) . ')';
        } else {
            $result .= $ch;
        }
    }
    return $result;
}
function randStr() {
    $sz = rand(0, 20);
    $buf = '';
    for ($i = 0; $i < $sz; $i++) {
        $what = rand(0, 19);
        switch ($what) {
            case 0: $buf .= "\r"; break;
            case 1: $buf .= "\n"; break;
            case 2: $buf .= "\t"; break;
            case 3: $buf .= "\f"; break;
            case 4: $buf .= ' '; break;
            case 5: $buf .= ','; break;
            case 6: $buf .= '"'; break;
            case 7: $buf .= "'"; break;
            case 8: $buf .= "\\"; break;
            default: $buf .= chr(rand(0, 299)); break;
        }
    }
    return $buf;
}
function doRandom($iter) {
    for ($i = 0; $i < $iter; $i++) {
        $nLines = rand(1, 4);
        $nCol = rand(1, 3);
        $lines = [];
        for ($j = 0; $j < $nLines; $j++) {
            $line = [];
            for ($k = 0; $k < $nCol; $k++) {
                $line[] = randStr();
            }
            $lines[] = $line;
        }
        $result = '';
        foreach ($lines as $line) {
            $result .= implode(',', array_map(function($v) {
                return '"' . str_replace('"', '""', $v) . '"';
            }, $line)) . "\n";
        }
        $parseResult = explode("\n", trim($result));
        foreach ($lines as $i => $line) {
            $parsedLine = explode(',', $parseResult[$i]);
            for ($j = 0; $j < count($line); $j++) {
                if ($line[$j] !== trim($parsedLine[$j], '"')) {
                    break;
                }
            }
        }
    }
}
$iter = 10000;
doRandom($iter);
function foo() {
    $a = array(1,2,3);
    $b=&$a;
    $b=1;
    $a = new stdClass;
    $a->a=1;
    $a->b=2;
    $b=&$a;
}
foo();
echo "ok\n";
var_dump(get_defined_vars());
} catch (\Throwable $_ffl_e) {}
```

Resulted in this output:

```
php: ext/opcache/jit/zend_jit_trace.c:361: uint32_t zend_jit_trace_type_to_info_ex(uint8_t, uint32_t): Assertion `info & (1 << type)' failed.
Aborted (core dumped)

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30

Deprecated: chr(): Providing a value not in-between 0 and 255 is deprecated, this is because a byte value must be in the [0, 255] interval. The value used will be constrained using % 256 in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/3534aec2.php on line 30
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php -d disable_functions=pcntl_fork,pcntl_exec,pcntl_alarm,pcntl_wait,pcntl_waitpid,pcntl_signal,pcntl_wexitstatus,pcntl_wifexited,pcntl_wifsignaled,posix_kill,posix_mkfifo,posix_setuid,posix_setgid,posix_setsid,system,exec,shell_exec,passthru,proc_open,popen,chmod,chown,chgrp,chdir,chroot,mkdir,rmdir,rename,unlink,link,symlink,copy,fsockopen,pfsockopen -d open_basedir="/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d allow_url_fopen=0 -d allow_url_include=0 -d include_path=".:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d opcache.enable=1 -d opcache.enable_cli=1 -d opcache.file_update_protection=0 -d opcache.enable=1 -d opcache.enable=1 -d opcache.enable_cli=1 -d opcache.jit=1254 "$SCRIPT_DIR/test.php"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `fccdabf3` | Bug corpus (project: `inferredbugs-java`, name: `commons-csv/110/file_before.txt`) |
| `b` | `23446162` | Project seed (`JIT ASSIGN: 026`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
