*Fusion-Fuzz Bug Report*

**ID:** `cbc05c9b` &nbsp;·&nbsp; **Signature:** `Assertion:0` &nbsp;·&nbsp; **RC:** `134`

The following code:

```php
<?php
try {
try { $cls = new LibXMLError(); } catch (\Throwable $_e) { $cls = new stdClass(); }
try { $clsAttr=$cls->code; } catch (\Throwable $_e) {}
class LType {
    public string $name;
    public function __construct(string $name) { $this->name = $name; }
}
class LTypes {
    public static LType $Bool;
    public static LType $Date;
    public static LType $Time;
    public static LType $Number;
    public static LType $String;
    public static LType $Array;
    public static LType $Map;
    public static LType $Null;
    public static LType $Object;
}
LTypes::$Bool = new LType('Bool');
LTypes::$Date = new LType('Date');
LTypes::$Time = new LType('Time');
LTypes::$Number = new LType('Number');
LTypes::$String = new LType('String');
LTypes::$Array = new LType('Array');
LTypes::$Map = new LType('Map');
LTypes::$Null = new LType('Null');
LTypes::$Object = new LType('Object');
class LObject {
    public LType $type;
    protected $value;
    public function __construct($value = null, ?LType $type = null) { $this->value = $value; $this->type = $type ?? LTypes::$Object; }
    public function getValue() { return $this->value; }
}
class LNumber extends LObject { public function __construct($v) { parent::__construct((float)$v, LTypes::$Number); } }
class LString extends LObject { public function __construct($v) { parent::__construct((string)$v, LTypes::$String); } }
class LBool extends LObject { public function __construct($v) { parent::__construct((bool)$v, LTypes::$Bool); } }
class LArray extends LObject { public function __construct($v) { parent::__construct($v, LTypes::$Array); } }
class LMap extends LObject { public function __construct($v) { parent::__construct($v, LTypes::$Map); } }
$args = [1, 2.5, "3", true, null, [new LNumber(4), new LString("5")], ["a" => 1, "b" => 2]];
for ($i = 0; $i < count($args); $i++) {
    $v = $args[$i];
    if ($v === null) $args[$i] = new LObject(null, LTypes::$Null);
    elseif (is_int($v) || is_float($v)) $args[$i] = new LNumber($v);
    elseif (is_string($v)) $args[$i] = new LString($v);
    elseif (is_bool($v)) $args[$i] = new LBool($v);
    elseif (is_array($v) && array_keys($v) === range(0, count($v) - 1)) $args[$i] = new LArray($v);
    elseif (is_array($v)) $args[$i] = new LMap($v);
}
$out = [];
foreach ($args as $v) $out[] = $v instanceof LObject ? $v->getValue() : $v;
echo json_encode($out), PHP_EOL;
class Player {
    public $name;
    public $world;
    function __construct($name, $world) {
        $this->name = $name;
        $this->world = $world;
    }
    function teleport($location) {
        // Simulate teleporting the player
        echo "Teleported " . $this->name . " to " . $location->x . "," . $location->y . "," . $location->z . "\n";
    }
}
class Location {
    public $world;
    public $x;
    public $y;
    public $z;
    function __construct($world, $x, $y, $z) {
        $this->world = $world;
        $this->x = $x;
        $this->y = $y;
        $this->z = $z;
    }
}
function getInteger($value, $min, $max) {
    $intValue = intval($value);
    if ($intValue < $min || $intValue > $max) {
        return null;
    }
    return $intValue;
}
$world = "world";
$player = new Player("Steve", $world);
$args = ["Steve", "30000001", "0", "30000001"]; // simulate input args
if (count($args) < 1 || count($args) > 4) {
    echo "Usage: /tp [player] <target>\n/tp [player] <x> <y> <z>\n";
    exit;
}
if (count($args) == 1 || count($args) == 3) {
    // Simulating sender being a player
} else {
    $target = new Player($args[0], $world); // simulate getting target player
}
if (!isset($target)) {
    echo "Player not found: " . $args[0] . "\n";
}
if (count($args) < 3) {
    // Simulate finding target player
    $target = new Player($args[count($args) - 1], $world); // simulate getting target player
    if (!isset($target)) {
        echo "Can't find user " . $args[count($args) - 1] . ". No tp.\n";
    }
    $player->teleport($target);
} else if ($player->world != null) {
    $x = getInteger($args[count($args) - 3], -30000000, 30000000);
    $y = getInteger($args[count($args) - 2], 0, 256);
    $z = getInteger($args[count($args) - 1], -30000000, 30000000);
    $location = new Location($player->world, $x, $y, $z);
    $player->teleport($location);
}
var_dump(get_defined_vars());
try { deflate_init($fusion,$fusion); } catch (\Throwable $e) {};
try { deflate_init($cls,$cls); } catch (\Throwable $e) {};
try { deflate_init($clsAttr,$fusion); } catch (\Throwable $e) {};
try { deflate_init($clsAttr,$clsAttr); } catch (\Throwable $e) {};
try { deflate_init($fusion,$cls); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}
```

Resulted in this output:

```
php: /home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/Zend/zend_operators.c:463: zend_long zendi_try_get_long(const zval *, _Bool *): Assertion `0' failed.
Aborted (core dumped)
[1,2.5,"3",true,null,[{"type":{"name":"Number"}},{"type":{"name":"String"}}],{"a":1,"b":2}]
Teleported Steve to ,0,
array(20) {
  ["argv"]=>
  array(1) {
    [0]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
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
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
    ["SCRIPT_NAME"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
    ["SCRIPT_FILENAME"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
    ["PATH_TRANSLATED"]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
    ["DOCUMENT_ROOT"]=>
    string(0) ""
    ["REQUEST_TIME_FLOAT"]=>
    float(1.7796E+9)
    ["REQUEST_TIME"]=>
    int(1779626154)
    ["argv"]=>
    array(1) {
      [0]=>
      string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
    }
    ["argc"]=>
    int(1)
  }
  ["cls"]=>
  object(LibXMLError)#1 (0) {
    ["level"]=>
    uninitialized(int)
    ["code"]=>
    uninitialized(int)
    ["column"]=>
    uninitialized(int)
    ["message"]=>
    uninitialized(string)
    ["file"]=>
    uninitialized(string)
    ["line"]=>
    uninitialized(int)
  }
  ["_e"]=>
  object(Error)#2 (7) {
    ["message":protected]=>
    string(76) "Typed property LibXMLError::$code must not be accessed before initialization"
    ["string":"Error":private]=>
    string(0) ""
    ["code":protected]=>
    int(0)
    ["file":protected]=>
    string(68) "/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php"
    ["line":protected]=>
    int(4)
    ["trace":"Error":private]=>
    array(0) {
    }
    ["previous":"Error":private]=>
    NULL
  }
  ["args"]=>
  array(4) {
    [0]=>
    string(5) "Steve"
    [1]=>
    string(8) "30000001"
    [2]=>
    string(1) "0"
    [3]=>
    string(8) "30000001"
  }
  ["i"]=>
  int(7)
  ["v"]=>
  object(LMap)#20 (2) {
    ["type"]=>
    object(LType)#9 (1) {
      ["name"]=>
      string(3) "Map"
    }
    ["value":protected]=>
    array(2) {
      ["a"]=>
      int(1)
      ["b"]=>
      int(2)
    }
  }
  ["out"]=>
  array(7) {
    [0]=>
    float(1)
    [1]=>
    float(2.5)
    [2]=>
    string(1) "3"
    [3]=>
    bool(true)
    [4]=>
    NULL
    [5]=>
    array(2) {
      [0]=>
      object(LNumber)#12 (2) {
        ["type"]=>
        object(LType)#6 (1) {
          ["name"]=>
          string(6) "Number"
        }
        ["value":protected]=>
        float(4)
      }
      [1]=>
      object(LString)#13 (2) {
        ["type"]=>
        object(LType)#7 (1) {
          ["name"]=>
          string(6) "String"
        }
        ["value":protected]=>
        string(1) "5"
      }
    }
    [6]=>
    array(2) {
      ["a"]=>
      int(1)
      ["b"]=>
      int(2)
    }
  }
  ["world"]=>
  string(5) "world"
  ["player"]=>
  object(Player)#21 (2) {
    ["name"]=>
    string(5) "Steve"
    ["world"]=>
    string(5) "world"
  }
  ["target"]=>
  object(Player)#19 (2) {
    ["name"]=>
    string(5) "Steve"
    ["world"]=>
    string(5) "world"
  }
  ["x"]=>
  NULL
  ["y"]=>
  int(0)
  ["z"]=>
  NULL
  ["location"]=>
  object(Location)#18 (4) {
    ["world"]=>
    string(5) "world"
    ["x"]=>
    NULL
    ["y"]=>
    int(0)
    ["z"]=>
    NULL
  }
}

Warning: Undefined variable $fusion in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 114

Warning: Undefined variable $fusion in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 114

Deprecated: deflate_init(): Passing null to parameter #1 ($encoding) of type int is deprecated in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 114

Warning: Undefined variable $clsAttr in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 116

Warning: Undefined variable $fusion in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 116

Deprecated: deflate_init(): Passing null to parameter #1 ($encoding) of type int is deprecated in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 116

Warning: Undefined variable $clsAttr in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 117

Warning: Undefined variable $clsAttr in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 117

Deprecated: deflate_init(): Passing null to parameter #1 ($encoding) of type int is deprecated in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 117

Warning: Undefined variable $fusion in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 118

Deprecated: deflate_init(): Passing null to parameter #1 ($encoding) of type int is deprecated in /home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared/cbc05c9b.php on line 118
```

To reproduce:

```
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
/home/fuzz/WorkSpace/fusion-fuzz/projects/php/php-src/sapi/cli/php -d disable_functions=pcntl_fork,pcntl_exec,pcntl_alarm,pcntl_wait,pcntl_waitpid,pcntl_signal,pcntl_wexitstatus,pcntl_wifexited,pcntl_wifsignaled,posix_kill,posix_mkfifo,posix_setuid,posix_setgid,posix_setsid,system,exec,shell_exec,passthru,proc_open,popen,chmod,chown,chgrp,chdir,chroot,mkdir,rmdir,rename,unlink,link,symlink,copy,fsockopen,pfsockopen -d open_basedir="/home/fuzz/WorkSpace/fusion-fuzz/.fused/php_exec_shared:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d allow_url_fopen=0 -d allow_url_include=0 -d include_path=".:/home/fuzz/WorkSpace/fusion-fuzz/projects/php/phpt_deps" -d serialize_precision=5 "$SCRIPT_DIR/test.php"
```

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `7c6ad284` | Bug corpus (project: `inferredbugs-csharp`, name: `SambaPOS-3/1/file_before.txt`) |
| `b` | `16113469` | Bug corpus (project: `inferredbugs-java`, name: `Spigot-API/4/file_before.txt`) |

*This report is automatically generated by [Fusion-Fuzz](https://github.com/0599jiangyc/FusionFuzzLoop)*
