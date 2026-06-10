CLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	TEXMFHOME=~/workspace/texmf latexmk -xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape resume

clean:
	latexmk -c resume.tex