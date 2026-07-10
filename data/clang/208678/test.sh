#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' clang++ -emit-llvm -S -o /dev/null -Os -std=gnu++20 -fstrict-enums -fsanitize=address "$SCRIPT_DIR/test.mm"
