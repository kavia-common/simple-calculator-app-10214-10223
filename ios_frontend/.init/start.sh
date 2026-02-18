#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
[ -f /etc/profile.d/swift.sh ] && . /etc/profile.d/swift.sh
# Build if executable missing
[ -x ".build/debug/demo" ] || swift build --configuration debug >>"$WORKSPACE/demo.log" 2>&1 || true
# Start via setsid and record pid/pgid
setsid bash -c '.init/run_demo.sh' >>"$WORKSPACE/demo.log" 2>&1 &
PID=$!
echo "$PID" > demo.pid
PGID=$(ps -o pgid= "$PID" | tr -d ' ')
echo "$PGID" > demo.pgid
