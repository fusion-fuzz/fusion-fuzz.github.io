#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ulimit -v 3145728; ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' flang -emit-llvm -S -o /dev/null -O1 -ffree-form -std=f2018 -g -fimplicit-none -falternative-parameter-statement "$SCRIPT_DIR/test.F90"
