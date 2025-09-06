# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

music:
	@$(PY39) -m venv _music
	( \
		source _music/bin/activate; \
		_music/bin/python -m pip install --upgrade pip; \
		_music/bin/python -m pip install -rrequirements-test.txt; \
        )

