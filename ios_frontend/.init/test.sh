#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
[ -f /etc/profile.d/swift.sh ] && . /etc/profile.d/swift.sh
# Try parallel; fall back if unsupported
if swift test --parallel -q >>"$WORKSPACE/test.log" 2>&1; then exit 0; else swift test -q >>"$WORKSPACE/test.log" 2>&1; fi
