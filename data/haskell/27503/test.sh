#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
/opt/ghc/9.14.1/bin/ghc -fno-code -v0 -O2 "$SCRIPT_DIR/test.hs"
