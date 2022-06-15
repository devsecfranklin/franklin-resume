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


"""my_resume application

    Test like so: python3 -m pytest tests/

    :copyright: © 2021 by Franklin Diaz
    :license: MIT
"""
