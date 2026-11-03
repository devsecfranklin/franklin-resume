# Build Instructions

## Prerequisites

- A LaTeX distribution (e.g., TeX Live)
- `latexmk`
- GNU Autotools (`autoconf`, `automake`)
- Python 3.9+

## Building with Autotools

```bash
./bootstrap.sh && ./configure && make
make clean   # remove build artifacts
```

## Building with TeXstudio

Configure your compiler for **XeLaTeX** rather than pdfLaTeX. Update the magic comment in `resume/resume.tex`:

```tex
% !TeX TXS-program:compile = txs:///xelatex/[--shell-escape]
```

## Project Structure

| Path | Purpose |
|---|---|
| `resume/resume.tex` | Document entry point |
| `resume/_header.tex` | Header formatting and contact info |
| `resume/fed-resume.sty` | Custom LaTeX style file |
| `resume/sections/` | Individual resume sections (experience, education, etc.) |
| `resume/images/` | Visual assets |
| `certification/` | Supporting certificate files |

## Running Go Tests

The repository includes Go-based integrity tests (`test/asset_test.go`, `test/link_test.go`):

```bash
cd test/
go test -v ./...
go test -v -coverprofile=coverage.out ./...   # with coverage
```

### TEST_CI Environment Variable

`TestLinkIntegrity` (in `link_test.go`) performs live HTTP requests against URLs found in `.tex`/`.md` source files. These are flaky in CI environments behind corporate firewalls or cloud runners.

- **Local development:** Tests run by default — set `TEST_CI=1` to skip link checking.
- **CI (GitHub Actions):** Link tests are automatically skipped; asset integrity checks still run regardless of environment.

### Coverage Report

```bash
go test -v -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html  # open in browser
```

## CI/CD

GitHub Actions (`.github/workflows/latex.yaml`) builds the resume on every pull request using [`xu-cheng/latex-action`](https://github.com/xu-cheng/latex-action).

Security & integrity tests run via `.github/workflows/security-scan.yml`, triggered on pushes and PRs touching `*.go`, `go.mod`, or `go.sum`. It checks Go dependency freshness (via `bootstrap.sh` + `go mod tidy`), runs asset/link integrity tests, and uploads coverage reports as artifacts for 14 days.
