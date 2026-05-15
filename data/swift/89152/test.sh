#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1:detect_stack_use_after_return=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' swift -frontend -emit-ir -O -sil-verify-all -enable-experimental-feature NonescapableTypes "$SCRIPT_DIR/test.swift"
