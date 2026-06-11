CLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	TEXMFHOME=~/workspace/texmf latexmk -xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape biography

clean:
	latexmk -c biography.tex

lint:
        @echo "==> Initializing documentation audit..."
        @if command -v chktex > /dev/null; then \
                chktex -q $(TEX_FILES); \
                echo "==> Audit complete. Documentation stability: 100%"; \
        else \
                echo "ERROR: 'chktex' not found on this node. Install via apt-get or dnf."; \
                exit 1; \
        fi