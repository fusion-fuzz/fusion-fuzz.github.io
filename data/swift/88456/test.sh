#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
swiftc -typecheck -Onone -sil-verify-all -enable-library-evolution "$SCRIPT_DIR/test.swift"
