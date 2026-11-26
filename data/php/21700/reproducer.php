<?php
class mystream {
function stream_open($path, $mode, $options, &$opened_path) { return true; }
function stream_seek($offset, $whence) {
$this->pos = $offset; // SEEK_CUR with negative offset → negative pos
return true;
}
function stream_tell() { return $this->pos; }
}
stream_wrapper_register("test", "mystream");
$fp = fopen("test://foo", "rb");
fseek($fp, -1, SEEK_CUR);
fseek($fp, 0, SEEK_CUR);
