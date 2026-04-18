# Franklin Diaz - Resume

[![LaTeX build](https://github.com/devsecfranklin/franklin-resume/actions/workflows/latex.yaml/badge.svg)](https://github.com/devsecfranklin/franklin-resume/actions/workflows/latex.yaml)

- [here is the PDF file](https://github.com/devsecfranklin/franklin-resume/blob/ceb25740e386654e7e7e637c114389b814c6a308/resume/resume.pdf)

## Project Overview

This project is a LaTeX-based resume with an automated build system using GNU Autotools. 

## Project Structure

* **`resume/resume.tex`**: The entry point for the LaTeX document.
* **`resume/_header.tex`**: Handles formatting for the document header and contact info.
* **`resume/fed-resume.sty`**: A custom LaTeX style file containing the formatting details.
* **`resume/sections/`**: Individual LaTeX files for different resume parts (e.g., experience, education).
* **`resume/images/`** & **`certification/`**: Directories used to store supporting visual assets and certificates.
* **`bootstrap.sh`** & **`configure.ac`**: Scripts and configuration for initializing the Autotools build system.
* **`Makefile` / `Makefile.am`**: Automake configuration for building the PDF using `latexmk`.
* **`.github/`**: Contains GitHub Actions workflows for continuous integration.

## Prerequisites

To compile the resume locally, you will need the following installed:
* A LaTeX distribution (e.g., TeX Live)
* `latexmk`
* GNU Autotools (`autoconf`, `automake`)
* Python 3.9+

## Building the Resume

**Using Autotools & Make (Terminal):**
1. Run `./bootstrap.sh` to initialize the build system and generate the `configure` script.
2. Run `./configure` (if applicable) and then run `make` or `make all` to compile the PDF.
3. Run `make clean` to remove build artifacts.

**Using TeXstudio:**
If you are editing the resume in TeXstudio, ensure your compiler is configured for **XeLaTeX** rather than pdfLaTeX. Update the magic comment at the top of `resume.tex` to:
`% !TeX TXS-program:compile = txs:///xelatex/[--shell-escape]`

## CI/CD Workflow

The repository uses GitHub Actions (`.github/workflows/latex.yaml`) to automatically build the resume on pull requests, utilizing the `xu-cheng/latex-action` action.
