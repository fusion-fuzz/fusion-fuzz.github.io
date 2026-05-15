#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASAN_OPTIONS='abort_on_error=1:detect_leaks=0:symbolize=1' UBSAN_OPTIONS='print_stacktrace=1:halt_on_error=1' /home/fuzz/WorkSpace/fusion-fuzz/projects/mlir/llvm-mlir-install/bin/mlir-opt --split-input-file --allow-unregistered-dialect --loop-invariant-code-motion --inline --sccp "$SCRIPT_DIR/test.mlir"
