#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
swiftc -sil-verify-all "$SCRIPT_DIR/test.swift"
