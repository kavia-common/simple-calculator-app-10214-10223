#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
[ -f /etc/profile.d/swift.sh ] && . /etc/profile.d/swift.sh
swift build --configuration debug
