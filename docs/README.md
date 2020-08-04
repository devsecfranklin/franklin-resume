# generate PDF

```bash
make docker
python3 -m pip install rst2pdf
pandoc --from=markdown --to=rst --output=resume.rst resume.md
rst2pdf resume.rst resume.pdf
```
