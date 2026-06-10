CLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	TEXMFHOME=~/workspace/texmf latexmk -xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape biography

clean:
	latexmk -c biography.tex
