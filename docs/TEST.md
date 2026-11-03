# Testing Infrastructure

## Overview

The Franklin Resume project includes a Go-based testing harness (`./test/`) that validates resume integrity, file permissions, LaTeX integration, and link health. Tests run both locally and in CI via GitHub Actions.

## Test Suite Structure

### Package: `resumescan`

All tests live in the `test/` directory as a single Go package.

#### TestBiographyIntegrity

Validates the biography/objective section of the resume against three sub-rules:

| Sub-test | Checks |
|---|---|
| `FilePermissions` | Biography file must have `0644` (`-rw-r--r--`) permissions. Any deviation flags a security risk. |
| `DraftPlaceholderScan` | Scans biography content for forbidden tokens: `TODO`, `FIXME`, `INSERT HERE`, `LOREM IPSUM`, `PLACEHOLDER`. Fails if any are found in production material. |
| `VerifyMainResumeIntegration` | Verifies the biography/objective file is actively referenced via `\input{sections/<name>}` in `resume/resume.tex`. Must be a real reference, not a commented-out line. |

### TestLinkIntegrity

Validates that all URLs and resources referenced within the resume are reachable. This test makes outbound HTTP requests and is **inherently flaky** in CI environments behind corporate firewalls or restrictive egress rules.

## Running Tests

From the repository root:

```sh
# Run all tests verbosely
go test -v ./test/...

# Generate coverage report (text)
go test -coverprofile=coverage.out ./test/...

# Open coverage in browser
go tool cover -html=coverage.out -o coverage.html

# Run only the biography integrity suite
go test -v -run=^TestBiographyIntegrity$ ./test/...

# Run a specific sub-test
go test -v -run=TestBiographyIntegrity/FilePermissions ./test/...

# Fail on first test failure (faster CI feedback)
go test -failfast ./test/...

# JSON-formatted output for programmatic parsing
go test -json ./test/... > test-report.json

# Compile binary (for standalone execution)
go test -c -o security_scanner.test ./test/
```

### Skipped Tests

To list all available tests without running:

```sh
go test -list . ./test/...
```

## CI Gate: `TEST_CI` Environment Variable

The `TestLinkIntegrity` suite performs outbound HTTP checks against URLs embedded in the resume. In CI environments with restricted egress (GitHub Actions, corporate proxies), this test is unreliable.

Set `TEST_CI=1` to automatically skip link integrity checks:

```sh
TEST_CI=1 go test -v ./test/...
```

When `TEST_CI=1`, the link test logs a skip and returns success rather than failing on unreachable hosts. The GitHub Actions workflow sets this automatically when running in the CI environment.

## Makefile

A `test` target is available via `make test`:

```sh
make test
```

This runs `go mod tidy`, executes tests with coverage, and generates an HTML report at `test/coverage.html`.

## Coverage Output

| File | Format | Location |
|---|---|---|
| `coverage.out` | Go text format (`go tool cover`) | Repository root |
| `test/coverage.out` | Same (Makefile variant) | `test/` directory |
| `coverage.html` | HTML report (`go tool cover -html`) | Repository root |
| `test-report.json` | JSON test events (`go test -json`) | Generated on demand |

## Source Files

| File | Purpose |
|---|---|
| `test/asset_test.go` | `TestBiographyIntegrity` suite — file permissions, placeholder scan, LaTeX integration |
| `test/link_test.go` | `TestLinkIntegrity` — URL reachability validation with `TEST_CI` skip gate |
| `test/note.txt` | Test design notes and rationale |
