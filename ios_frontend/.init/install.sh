#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
# Minimal install: ensure clang present (build-essential present per image)
sudo apt-get update -qq && sudo apt-get install -y -qq clang ca-certificates || true
# Do not install Swift toolchain here automatically in script to avoid long downloads; rely on env provisioning step.
# Ensure profile.d placeholder for swift_workspace exists
sudo tee /etc/profile.d/swift_workspace.sh >/dev/null <<'EOF'
export SWIFT_WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
EOF
