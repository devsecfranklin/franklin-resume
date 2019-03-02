# -*- coding: utf-8 -*-

"""
    my_resume application

    Test like so: python3 -m pytest tests/

    :copyright: (c) by Franklin Diaz
    :license: MIT
"""

import unittest
import pytest

from my_resume.my_resume import create_app

class TestCase(unittest.TestCase):
  def setUp(self):
    self.app = create_app(debug=True)
    self.client = self.app.test_client()

@pytest.fixture
def app():
  app = create_app(debug=True)
  return app