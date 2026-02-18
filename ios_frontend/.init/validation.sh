#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
LOG="$WORKSPACE/validation.log"
: >"$LOG"
[ -f /etc/profile.d/swift.sh ] && . /etc/profile.d/swift.sh
[ -f /etc/profile.d/swift_workspace.sh ] && . /etc/profile.d/swift_workspace.sh
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not available" | tee -a "$LOG"; exit 2; }
# build
if ! swift build --configuration debug >>"$LOG" 2>&1; then echo "ERROR: build failed - see $LOG" | tee -a "$LOG"; tail -n 200 "$LOG" || true; exit 3; fi
# tests
if ! swift test -q >>"$LOG" 2>&1; then echo "ERROR: tests failed - see $LOG" | tee -a "$LOG"; tail -n 200 "$LOG" || true; exit 4; fi
# start demo
# prefer canonical start script
.init/start.sh >>"$LOG" 2>&1 || true
if [ -f "$WORKSPACE/demo.pid" ]; then PID=$(cat "$WORKSPACE/demo.pid") || true; else setsid bash -c '.init/run_demo.sh' >>"$LOG" 2>&1 & PID=$!; sleep 1; fi
echo "DEMO_PID=$PID" >>"$LOG"
PGID=$( [ -f "$WORKSPACE/demo.pgid" ] && cat "$WORKSPACE/demo.pgid" || ps -o pgid= "$PID" | tr -d ' ' )
sleep 3
if [ -n "$PGID" ]; then kill -TERM -"$PGID" >>"$LOG" 2>&1 || true; sleep 1; kill -KILL -"$PGID" >>"$LOG" 2>&1 || true; fi
wait "$PID" 2>/dev/null || true
echo "VALIDATION_COMPLETED" >>"$LOG"
rm -f "$WORKSPACE/demo.pid" "$WORKSPACE/demo.pgid"
tail -n 200 "$LOG" || true
exit 0
