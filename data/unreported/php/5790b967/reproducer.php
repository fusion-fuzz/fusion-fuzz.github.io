<?php
$ctx = stream_context_create(["http" => ["timeout" => NAN]]);
@file_get_contents("http://127.0.0.1:1/", false, $ctx);
