CLOCAL_AMFLAGS = -I config/m4 -I aclocal

all:
	cd resume && TEXMFHOME=~/workspace/texmf latexmk -xelatex -file-line-error -interaction=nonstopmode -synctex=1 -shell-escape resume

clean:
	cd resume/ && latexmk -C
	rm -rf _build/ *.egg-info
	rm coverage.html coverage.out security_scanner.test
	rm -rf autom4te.cache/
	rm -f config.log config.status Makefile Makefile.in configure aclocal.m4

.PHONY: test
test:
	go mod tidy
	go test -coverprofile=test/coverage.out ./test/...
	go tool cover -html=test/coverage.out -o test/coverage.html
