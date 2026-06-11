all:
	cd resume && TEXMFHOME=~/workspace/texmf latexmk -xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape resume

clean:
	cd reusme && latexmk -C
	rm -rf _build/ *.egg-info

distclean-local:
	rm -rf autom4te.cache/
	rm -f config.log config.status Makefile Makefile.in configure aclocal.m4
