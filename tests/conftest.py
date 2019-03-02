# -*- coding: utf-8 -*-
"""Defines fixtures available to all tests."""

from my_resume import create_app

@pytest.fixture
def app():
  app = create_app()
  return app
