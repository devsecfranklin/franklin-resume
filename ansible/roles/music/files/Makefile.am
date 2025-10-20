music:
	@$(PY39) -m venv _music
	( \
		source _music/bin/activate; \
		_music/bin/python -m pip install --upgrade pip; \
		_music/bin/python -m pip install -rrequirements-test.txt; \
        )
