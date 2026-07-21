#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/clang/llvm-clang-install/bin/clang++ -fsyntax-only -Oz -std=gnu++20 -fstrict-enums "$SCRIPT_DIR/test.mm"
