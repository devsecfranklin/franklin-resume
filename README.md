# Franklin Resume

[![LaTeX build](https://github.com/devsecfranklin/franklin-resume/actions/workflows/latex.yaml/badge.svg)](https://github.com/devsecfranklin/franklin-resume/actions/workflows/latex.yaml)

This project contains a LaTeX-based resume with an automated build system using GNU Autotools.

*   **[View the latest PDF resume](https://github.com/devsecfranklin/franklin-resume/blob/main/resume.pdf)**

## Development Workflow

This project uses a standard Autotools workflow to build the resume PDF from the LaTeX source.

### Prerequisites

-   LaTeX distribution (e.g., TeX Live)
-   `latexmk`
-   GNU Autotools (`autoconf`, `automake`)
-   Python 3.9+

### Build Process

1.  **Initialize:** Run `./bootstrap.sh` to generate the `configure` script and initialize the build environment.
    ```bash
    ./bootstrap.sh
    ```

2.  **Build:** Run `make` inside the `resume/` directory to compile the LaTeX source into a PDF.
    ```bash
    cd resume/
    make
    ```
    The output will be `resume.pdf` in the root of the project.

3.  **Clean:** To remove build artifacts, run `make clean` in the `resume/` directory.
    ```bash
    cd resume/
    make clean
    ```

## CI/CD

A GitHub Actions workflow automatically builds the resume on every pull request to ensure it compiles correctly.
