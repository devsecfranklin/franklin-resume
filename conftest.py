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


"""
Unit Tests
"""
class TestCase(unittest.TestCase):
  def setUp(self):
    self.app = create_app(debug=True)
    self.client = self.app.test_client()

"""
Python Tests
"""
@pytest.fixture
def app():
  app = create_app(debug=True)
  return app

@pytest.fixture(scope='module')
def test_client():
  flask_app = create_app('flask_test.cfg')
   
  # Flask provides a way to test your application by exposing the Werkzeug test Client
  # and handling the context locals for you.
  testing_client = flask_app.test_client()