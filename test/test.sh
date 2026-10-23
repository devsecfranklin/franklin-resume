#!/bin/bash
set -euo pipefail
pushd "$(dirname "$0")/.." | exit 1

echo "=== Running test suite ==="
go test -v -count=1 ./test/...
go test -coverprofile=coverage.out ./test/...
go tool cover -html=coverage.out -o coverage.html
echo "=== Coverage report written to coverage.html ==="
