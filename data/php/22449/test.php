<?php
try {
try { $cls = new SimpleXMLElement(); } catch (\Throwable $_e) { $cls = new stdClass(); }
stream_filter_register("rotator_notWorking", rotate_filter_nw::class);
session_start();
class rotate_filter_nw extends php_user_filter
{
    function filter($in, $out, &$consumed, $closing): int
    {
        while ($bucket = stream_bucket_make_writeable($in)) {
            $this->rotate($bucket->data);
            $consumed += $bucket->datalen;
            stream_bucket_prepend($out, $bucket);
        }
    $stream = fopen('php://memory', 'w+');
    stream_filter_append($stream, "rotator_notWorking");
        return PSFS_PASS_ON;
    }
    function rotate(&$data)
    {
        $n = strlen($data);
        for ($i = 0; $i < $_SESSION - 1; ++$i) {
            $data[$i] = $data[$i + 1];
        }
    }
}
$_SESSION['foo|bar'] = 'value';
$stream = fopen('php://memory', 'w+');
stream_filter_append($stream, "rotator_notWorking");
rewind($stream);
var_dump(stream_get_contents($stream));
fwrite($stream, 'hello, world');
var_dump(get_defined_vars());
try { $cls->hasChildren(); } catch (\Throwable $e) {};
try { $cls->hasChildren(); } catch (\Throwable $e) {};
try { $cls->hasChildren(); } catch (\Throwable $e) {};
try { $cls->hasChildren(); } catch (\Throwable $e) {};
try { $cls->hasChildren(); } catch (\Throwable $e) {};
} catch (\Throwable $_ffl_e) {}