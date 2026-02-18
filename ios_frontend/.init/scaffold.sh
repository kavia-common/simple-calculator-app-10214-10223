#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
# Backup existing files if present
for f in Package.swift Sources Tests; do [ -e "$f" ] && cp -a "$f" "$f.bak.$(date +%s)" || true; done
# Create minimal SwiftPM package if missing
if [ ! -f Package.swift ]; then cat >Package.swift <<'SW'
// swift-tools-version:5.7
import PackageDescription
let package = Package(
    name: "CalculatorApp",
    products: [ .executable(name: "demo", targets: ["App"]) , .library(name: "CalculatorLib", targets: ["CalculatorLib"])],
    targets: [
        .target(name: "CalculatorLib", path: "Sources/CalculatorLib"),
        .executableTarget(name: "App", dependencies: ["CalculatorLib"], path: "Sources/App"),
        .testTarget(name: "CalculatorLibTests", dependencies: ["CalculatorLib"], path: "Tests/CalculatorLibTests")
    ]
)
SW
fi
# Sources for calculator lib
mkdir -p Sources/CalculatorLib Sources/App Tests/CalculatorLibTests
cat >Sources/CalculatorLib/Calculator.swift <<'SW'
public struct Calculator {
    public init() {}
    public func add(_ a: Int, _ b: Int) -> Int { a + b }
    public func sub(_ a: Int, _ b: Int) -> Int { a - b }
    public func mul(_ a: Int, _ b: Int) -> Int { a * b }
    public func div(_ a: Int, _ b: Int) -> Int { b == 0 ? 0 : a / b }
}
SW
cat >Sources/App/main.swift <<'SW'
import CalculatorLib
import Foundation
let calc = Calculator()
print("Demo app started")
// Simple loop to write periodic output to demo.log when started via run_demo.sh
for i in 0..<60 { print("calc: 2+3=\(calc.add(2,3)) tick=\(i)"); fflush(stdout); sleep(1) }
SW
# Tests
cat >Tests/CalculatorLibTests/CalculatorTests.swift <<'SW'
import XCTest
@testable import CalculatorLib
final class CalculatorTests: XCTestCase {
    func testAdd() { XCTAssertEqual(Calculator().add(1,2), 3) }
    func testSub() { XCTAssertEqual(Calculator().sub(5,3), 2) }
    func testMul() { XCTAssertEqual(Calculator().mul(3,4), 12) }
    func testDiv() { XCTAssertEqual(Calculator().div(8,2), 4) }
}
SW
# Helper scripts
cat >.init || true
mkdir -p .init
cat >.init/build.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
[ -f /etc/profile.d/swift.sh ] && . /etc/profile.d/swift.sh
swift build --configuration debug
SH
chmod +x .init/build.sh
cat >.init/run_demo.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
# Run the demo executable and redirect output to demo.log
exec "$(pwd)/.build/debug/demo" >>"$WORKSPACE/demo.log" 2>&1
SH
chmod +x .init/run_demo.sh
cat >.init/start.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
# start under new session and record pid/pgid
setsid bash -c '.init/run_demo.sh' >>"$WORKSPACE/demo.log" 2>&1 &
PID=$!
echo "$PID" > "$WORKSPACE/demo.pid"
PGID=$(ps -o pgid= "$PID" | tr -d ' ')
echo "$PGID" > "$WORKSPACE/demo.pgid"
SH
chmod +x .init/start.sh
cat >.init/stop.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-10214-10223/ios_frontend"
cd "$WORKSPACE"
PGID=""
[ -f demo.pgid ] && PGID=$(cat demo.pgid) || true
if [ -n "$PGID" ]; then kill -TERM -"$PGID" || true; sleep 1; kill -KILL -"$PGID" || true; fi
[ -f demo.pid ] && wait "$(cat demo.pid)" 2>/dev/null || true
rm -f demo.pid demo.pgid
SH
chmod +x .init/stop.sh
