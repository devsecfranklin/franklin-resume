# CV

Curriculum Vitae files for Franklin Diaz.

## Contents

| File | Purpose |
|------|---------|
| `curriculum-vitae.md` | Full narrative CV — source of truth, built from resume data |
| `cu-faculty-page.md` | Short faculty directory entry (matches Murdock-style format) |

## Building from Source

The authoritative resume source is `/home/franklin/franklin-resume/resume/` (LaTeX-based). The CV in this folder is derived from:

- `resume/resume.tex` — main document
- `resume/sections/experience.tex` — professional history
- `resume/sections/education.tex` — academic background
- `resume/sections/projects/projects.tex` — projects/publications
- `biography/bio.md` — biographical text

## Updates

When the LaTeX resume is updated, regenerate this CV by:

1. Reviewing changes to experience, education, and credentials
2. Updating `curriculum-vitae.md` accordingly
3. Updating `cu-faculty-page.md` for any CU Denver-facing submissions
