CLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	TEXMFHOME=~/workspace/texmf latexmk -xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape resume

clean:
	rm -rf _build *.egg-info
	@for trash in *.xdv *.fls *.fdb_latexmk *.aux *.bbl *.blg *.lof *.log *.lot *.out *.pdf *.synctex.gz *.toc INSTALL COPYING; do \
		if [ -f "$$trash" ]; then \
			rm -rf $$trash ; \
		fi ; \
	done
