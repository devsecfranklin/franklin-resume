# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import unittest
import pytest
from src.my_resume import create_app


class TestCase(unittest.TestCase):
    """Unit testing."""

    def setUp(self):
        self.app = create_app(debug=True)
        self.client = self.app.test_client()


@pytest.fixture
def app():
    """Create the app."""
    app = create_app(debug=True)
    return app


@pytest.fixture(scope="module")
def test_client():
    flaskr.app.config["TESTING"] = True
    client = flaskr.app.test_client()
    yield client
