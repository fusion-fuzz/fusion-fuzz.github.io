# SEGV at zend_call_known_fcc Zend/zend_API.h

**Issue:** [https://github.com/php/php-src/issues/21023](https://github.com/php/php-src/issues/21023) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2026-01-24T13:41:54Z`

**Labels:** `Bug`, `Extension: curl`, `Status: Verified`

## Description

### Description

The following code:

```php
<?php
include 'server.inc';
$host = curl_cli_server_start();
$url = "{$host}/get.inc";
$ch = curl_init($url);
curl_setopt($ch, CURLOPT_NOPROGRESS, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_XFERINFOFUNCTION, $callback);
echo curl_exec($ch), PHP_EOL;
var_dump(get_defined_vars());
```

Resulted in this output:
```
Warning: Undefined variable $callback in /tmp/test.php on line 8
/home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_API.h:847:6: runtime error: member access within null pointer of type 'zend_function' (aka 'union _zend_function')
    #0 0xf216d7 in zend_call_known_fcc /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_API.h:847:6
    #1 0xf25f59 in curl_xferinfo /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/curl/interface.c:659:2
    #2 0x7fcf70347052  (/lib/x86_64-linux-gnu/libcurl.so.4+0x4f052)
    #3 0x7fcf7033e487  (/lib/x86_64-linux-gnu/libcurl.so.4+0x46487)
    #4 0x7fcf703414cd in curl_multi_perform (/lib/x86_64-linux-gnu/libcurl.so.4+0x494cd)
    #5 0x7fcf7031deb2 in curl_easy_perform (/lib/x86_64-linux-gnu/libcurl.so.4+0x25eb2)
    #6 0xefdd9a in zif_curl_exec /home/phpfuzz/WorkSpace/flowfusion/php-src/ext/curl/interface.c:2342:10
    #7 0x5feecbf in ZEND_DO_ICALL_SPEC_RETVAL_USED_HANDLER /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:1421:2
    #8 0x5aff3fb in execute_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:116245:12
    #9 0x5b0198c in zend_execute /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_vm_execute.h:121962:2
    #10 0x6894569 in zend_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend.c:1980:3
    #11 0x5056eca in php_execute_script_ex /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2645:13
    #12 0x5058008 in php_execute_script /home/phpfuzz/WorkSpace/flowfusion/php-src/main/main.c:2685:9
    #13 0x68a947a in do_cli /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:951:5
    #14 0x68a385f in main /home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php_cli.c:1362:18
    #15 0x7fcf6fb10d8f in __libc_start_call_main csu/../sysdeps/nptl/libc_start_call_main.h:58:16
    #16 0x7fcf6fb10e3f in __libc_start_main csu/../csu/libc-start.c:392:3
    #17 0x606244 in _start (/home/phpfuzz/WorkSpace/flowfusion/php-src/sapi/cli/php+0x606244)

SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior /home/phpfuzz/WorkSpace/flowfusion/php-src/Zend/zend_API.h:847:6 in 
```

server.inc
```
<?php declare(strict_types=1);

function curl_cli_server_start() {
    $php_executable = getenv('TEST_PHP_EXECUTABLE') ?: PHP_BINARY;
    $doc_root = __DIR__;
    $router = "responder/get.inc";
    $cmd = [$php_executable, '-t', $doc_root, '-n', '-S', 'localhost:0', $router];
    $descriptorspec = array(
        0 => STDIN,
        1 => STDOUT,
        2 => ['pipe', 'w'],
    );
    $handle = proc_open($cmd, $descriptorspec, $pipes, $doc_root, null, array("suppress_errors" => true));

    // First, wait for the dev server to declare itself ready.
    $bound = null;
    stream_set_blocking($pipes[2], false);
    for ($i = 0; $i < 60; $i++) {
        usleep(50000); // 50ms per try
        $status = proc_get_status($handle);
        if (empty($status['running'])) {
            echo "Server is not running\n";
            proc_terminate($handle);
            exit(1);
        }

        while (($line = fgets($pipes[2])) !== false) {
            if (preg_match('@PHP \S* Development Server \(https?://(.*?:\d+)\) started@', $line, $matches)) {
                $bound = $matches[1];
                // Now that we've identified the listen address, close STDERR.
                // Otherwise the pipe may clog up with unread log messages.
                fclose($pipes[2]);
                break 2;
            }
        }
    }
    if ($bound === null) {
        echo "Server did not output startup message";
        proc_terminate($handle);
        exit(1);
    }

    // Now wait for a connection to succeed.
    // note: even when server prints 'Listening on localhost:8964...Press Ctrl-C to quit.'
    //       it might not be listening yet...need to wait until fsockopen() call returns
    $error = "Unable to connect to server\n";
    for ($i=0; $i < 60; $i++) {
        usleep(50000); // 50ms per try
        $status = proc_get_status($handle);
        $fp = @fsockopen("tcp://$bound");
        // Failure, the server is no longer running
        if (!($status && $status['running'])) {
            $error = "Server is not running\n";
            break;
        }
        // Success, Connected to servers
        if ($fp) {
            $error = '';
            break;
        }
    }

    if ($fp) {
        fclose($fp);
    }

    if ($error) {
        echo $error;
        proc_terminate($handle);
        exit(1);
    }

    register_shutdown_function(
        function($handle) {
            proc_terminate($handle);
            /* Wait for server to shutdown */
            for ($i = 0; $i < 60; $i++) {
                $status = proc_get_status($handle);
                if (!($status && $status['running'])) {
                    break;
                }
                usleep(50000);
            }
        },
        $handle
    );

    return $bound;
}
```

```

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
