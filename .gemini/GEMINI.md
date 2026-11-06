# Gemini Project Context: Franklin Resume

This repository maintains Franklin Diaz's living curriculum vitae, resume, and biography, typeset in LaTeX with an automated build system and a Go verification test suite.

## Project Invariants & Identity

- **Author:** Franklin Diaz
- **Primary Contact:** `franklin@bitsmasher.net` (Academic: `franklin.diaz@ucdenver.edu`)
- **Canonical GitHub Handle:** `devsecfranklin` (Never use deprecated handle `pale-shadow`)
- **Research Site:** `https://www.bitsmasher.net/research/`
- **LinkedIn:** `https://linkedin.com/in/franklin-diaz`

## Key Targets & Document Structure

- **Main Resume (`resume/`):**
  - Entry point: `resume/resume.tex`
  - Partials: `resume/_header.tex`, modular sections in `resume/sections/*.tex`
  - Style package: `resume/fed-resume.sty`
- **Biography (`biography/`):**
  - Entry point: `biography/biography.tex`
  - Partials: `biography/_header.tex`
  - Style package: `biography/monserrat.sty` (note single 't')
- **Curriculum Vitae (`cv/`):**
  - Sources: `cv/cv.tex`, `cv/curriculum-vitae.md`
- **Images (`images/`):**
  - Headshot: `images/Franklin_24-09-19_3869.jpg`
  - Visual assets: `images/bio-header-palo.png`, `images/ORCID.png`
- **Excluded Fixtures:**
  - `test/test.tex` is an isolated legacy driver fixture; do not alter or scan for identity checks.

## Compilation & Build Mechanics

- **Engine:** Always compile with **XeLaTeX** (`xelatex`) due to `fontspec` and OpenType/TrueType font dependencies (`biography/monserrat.sty`, `resume/fed-resume.sty`).
- **Standard Compile Flags:**
  ```bash
  xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape <document.tex>

