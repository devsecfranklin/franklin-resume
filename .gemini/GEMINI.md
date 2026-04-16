# Gemini Project Context: Franklin Resume

This project is a LaTeX-based resume with an automated build system using GNU Autotools.

## Project Overview

- **Goal:** Maintain and build a professional resume in PDF format from LaTeX source.
- **Main Source:** `resume/resume.tex`
- **Content Sections:** Located in `resume/sections/` (e.g., `experience.tex`, `education.tex`).
- **Styling:** Defined in `resume/TLCresume.sty`.

## Development Workflow

### Prerequisites

- LaTeX distribution (e.g., TeX Live)
- `latexmk`
- GNU Autotools (`autoconf`, `automake`)
- Python 3.9+ (as specified in `configure.ac`)

### Build Process

The project uses a standard Autotools workflow:

1.  **Initialize:** Run `./bootstrap.sh` to generate the `configure` script and run it.
2.  **Build:** Run `make` inside the `resume/` directory.
    - The `Makefile.am` in `resume/` uses `latexmk` to compile the PDF.
3.  **Clean:** Run `make clean` in the `resume/` directory to remove build artifacts.

### CI/CD

- GitHub Actions (`.github/workflows/latex.yaml`) automatically builds the resume on pull requests using `xu-cheng/latex-action` with `pdf`.

## Key Files and Directories

- `resume/`: Contains the main LaTeX source and build configuration.
    - `resume.tex`: The entry point for the LaTeX document.
    - `sections/`: Individual LaTeX files for different resume parts.
    - `TLCresume.sty`: Custom LaTeX style file.
    - `_header.tex`: Handles formatting for the document header and contact info.
    - `Makefile.am`: Automake configuration for building the PDF.
- `bootstrap.sh`: Script to initialize the build system.
- `configure.ac`: Autoconf configuration file.
- `images/`: Contains images used in the resume (e.g., headshot, QR codes).
- `certification/`: Directory for certification-related documents and notes.

## Coding Standards

- **LaTeX:** Follow standard LaTeX conventions. Use `UTF-8` encoding.
- **Structure:** Keep content modular by using `\input{sections/...}` in `resume.tex`.
- **Style:** Avoid hardcoding styles in section files; use `TLCresume.sty` for consistent formatting.
