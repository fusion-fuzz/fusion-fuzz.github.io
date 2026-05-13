# heap-buffer-overflow PyOS_StdioReadline Parser/myreadline.c

**Issue:** [https://github.com/python/cpython/issues/140594](https://github.com/python/cpython/issues/140594) &nbsp;·&nbsp; **State:** `closed` &nbsp;·&nbsp; **Created:** `2025-10-25T16:06:56Z`

**Labels:** `interpreter-core`, `type-crash`, `topic-parser`

## Description

# Crash report

### What happened?

```python
import sys
import subprocess
import unittest
def interpreter_requires_environment():
    return func
def spawn_python(*args):
    run_timeit_stub = False
    if run_timeit_stub:
        script = textwrap.dedent(r"""
        """)
        popen = subprocess.Popen([sys.executable, '-u', '-c', script],
                                 stderr=subprocess.STDOUT)
    popen = subprocess.Popen((sys.executable, *args),
                             stdin=subprocess.PIPE,
                             stderr=subprocess.STDOUT)
    return popen
    if out is float('inf'):
        return b''
class CmdLineTest(unittest.TestCase):
    p = spawn_python('-i', '-m', 'timeit', '-n', '1')
    try:
        p.stdin.write(b'\x00')
    except BrokenPipeError:
        pass
if __name__ == "__main__":
    unittest.main(verbosity=0)
```

```
=================================================================
==678651==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x50b000085f2f at pc 0x562565e308e3 bp 0x7ffcdc260930 sp 0x7ffcdc260920
READ of size 1 at 0x50b000085f2f thread T0
    #0 0x562565e308e2 in PyOS_StdioReadline ../Parser/myreadline.c:347
    #1 0x562565e30a79 in PyOS_Readline ../Parser/myreadline.c:411
    #2 0x562565e2940d in tok_underflow_interactive ../Parser/tokenizer/file_tokenizer.c:198
    #3 0x562565e1eb9c in tok_nextc ../Parser/lexer/lexer.c:75
    #4 0x562565e20af7 in tok_get_normal_mode ../Parser/lexer/lexer.c:521
    #5 0x562565e26825 in tok_get_fstring_mode ../Parser/lexer/lexer.c:1415
    #6 0x562565e26825 in tok_get ../Parser/lexer/lexer.c:1619
    #7 0x562565e26825 in _PyTokenizer_Get ../Parser/lexer/lexer.c:1626
    #8 0x562565d6f13e in _PyPegen_fill_token ../Parser/pegen.c:249
    #9 0x562565e1bbb7 in statement_newline_rule ../Parser/parser.c:1347
    #10 0x562565e1bbb7 in interactive_rule ../Parser/parser.c:1049
    #11 0x562565e1bbb7 in _PyPegen_parse ../Parser/parser.c:38326
    #12 0x562565d7309c in _PyPegen_run_parser ../Parser/pegen.c:942
    #13 0x562565d73ad2 in _PyPegen_run_parser_from_file_pointer ../Parser/pegen.c:1020
    #14 0x5625663d9869 in pyrun_one_parse_ast ../Python/pythonrun.c:269
    #15 0x5625663d9869 in PyRun_InteractiveOneObjectEx ../Python/pythonrun.c:300
    #16 0x5625663dd565 in _PyRun_InteractiveLoopObject ../Python/pythonrun.c:153
    #17 0x5625663dee2d in _PyRun_AnyFileObject ../Python/pythonrun.c:75
    #18 0x5625663dee2d in PyRun_AnyFileExFlags ../Python/pythonrun.c:102
    #19 0x56256645162f in pymain_repl ../Modules/main.c:599
    #20 0x56256645162f in pymain_run_python ../Modules/main.c:697
    #21 0x5625664533de in Py_RunMain ../Modules/main.c:772
    #22 0x5625664533de in pymain_main ../Modules/main.c:802
    #23 0x5625664533de in Py_BytesMain ../Modules/main.c:826
    #24 0x7650397c51c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #25 0x7650397c528a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

0x50b000085f2f is located 1 bytes before 100-byte region [0x50b000085f30,0x50b000085f94)
allocated by thread T0 here:
    #0 0x765039b92778 in realloc ../../../../src/libsanitizer/asan/asan_malloc_linux.cpp:85
    #1 0x562565e3065b in PyOS_StdioReadline ../Parser/myreadline.c:327
    #2 0x562565e30a79 in PyOS_Readline ../Parser/myreadline.c:411
    #3 0x562565e2940d in tok_underflow_interactive ../Parser/tokenizer/file_tokenizer.c:198
    #4 0x562565e1eb9c in tok_nextc ../Parser/lexer/lexer.c:75
    #5 0x562565e20af7 in tok_get_normal_mode ../Parser/lexer/lexer.c:521
    #6 0x562565e26825 in tok_get_fstring_mode ../Parser/lexer/lexer.c:1415
    #7 0x562565e26825 in tok_get ../Parser/lexer/lexer.c:1619
    #8 0x562565e26825 in _PyTokenizer_Get ../Parser/lexer/lexer.c:1626
    #9 0x562565d6f13e in _PyPegen_fill_token ../Parser/pegen.c:249
    #10 0x562565e1bbb7 in statement_newline_rule ../Parser/parser.c:1347
    #11 0x562565e1bbb7 in interactive_rule ../Parser/parser.c:1049
    #12 0x562565e1bbb7 in _PyPegen_parse ../Parser/parser.c:38326
    #13 0x562565d7309c in _PyPegen_run_parser ../Parser/pegen.c:942
    #14 0x562565d73ad2 in _PyPegen_run_parser_from_file_pointer ../Parser/pegen.c:1020
    #15 0x5625663d9869 in pyrun_one_parse_ast ../Python/pythonrun.c:269
    #16 0x5625663d9869 in PyRun_InteractiveOneObjectEx ../Python/pythonrun.c:300
    #17 0x5625663dd565 in _PyRun_InteractiveLoopObject ../Python/pythonrun.c:153
    #18 0x5625663dee2d in _PyRun_AnyFileObject ../Python/pythonrun.c:75
    #19 0x5625663dee2d in PyRun_AnyFileExFlags ../Python/pythonrun.c:102
    #20 0x56256645162f in pymain_repl ../Modules/main.c:599
    #21 0x56256645162f in pymain_run_python ../Modules/main.c:697
    #22 0x5625664533de in Py_RunMain ../Modules/main.c:772
    #23 0x5625664533de in pymain_main ../Modules/main.c:802
    #24 0x5625664533de in Py_BytesMain ../Modules/main.c:826
    #25 0x7650397c51c9  (/lib/x86_64-linux-gnu/libc.so.6+0x2a1c9) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)
    #26 0x7650397c528a in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x2a28a) (BuildId: 282c2c16e7b6600b0b22ea0c99010d2795752b5f)

SUMMARY: AddressSanitizer: heap-buffer-overflow ../Parser/myreadline.c:347 in PyOS_StdioReadline
Shadow bytes around the buggy address:
  0x50b000085c80: fd fd fd fd fd fd fd fd fd fd fd fa fa fa fa fa
  0x50b000085d00: fa fa fa fa fd fd fd fd fd fd fd fd fd fd fd fd
  0x50b000085d80: fd fa fa fa fa fa fa fa fa fa 00 00 00 00 00 00
  0x50b000085e00: 00 00 00 00 00 00 00 04 fa fa fa fa fa fa fa fa
  0x50b000085e80: 00 00 00 00 00 00 00 00 00 00 00 00 04 fa fa fa
=>0x50b000085f00: fa fa fa fa fa[fa]00 00 00 00 00 00 00 00 00 00
  0x50b000085f80: 00 00 04 fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x50b000086000: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x50b000086080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x50b000086100: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x50b000086180: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
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
==678651==ABORTING
```

### CPython versions tested on:

CPython main branch

### Operating systems tested on:

Linux

### Output from running 'python -VV' on the command line:

_No response_

<!-- gh-linked-prs -->
### Linked PRs
* gh-140910
* gh-145852
* gh-145853
<!-- /gh-linked-prs -->


---

### Parents

| Label | ID | Source |
|-------|----|--------|
| `a` | `` | `` |
| `b` | `` | `` |

*Program: (to be filled)*
