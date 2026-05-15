#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cmd: `docker run --rm -v "$PWD":/work -w /work swift:latest bash -lc 'swiftc -c "$SCRIPT_DIR/test.swift" -o /dev/null'`


### Stack dump
