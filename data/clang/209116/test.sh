#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -c -o /dev/null -Os -std=c++11 -fsanitize=address -fsanitize=undefined -Wextra "$SCRIPT_DIR/test.cpp"
