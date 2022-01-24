
build:
	python3 -m venv _build
	. _build/bin/activate
	python3 -m pip install --upgrade pip
	python3 -m pip install -rrequirements.txt
