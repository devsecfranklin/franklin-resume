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

## CI/CD

GitHub Actions (`.github/workflows/latex.yaml`) builds the resume on every pull request using [`xu-cheng/latex-action`](https://github.com/xu-cheng/latex-action).
