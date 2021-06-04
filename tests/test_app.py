# -*- coding: utf-8 -*-

"""
    my_resume application

    Test like so: python3 -m pytest tests/

    :copyright: (c) by Franklin Diaz
    :license: MIT
"""

from src.my_resume import create_app


def test_create_app(app):
    """
    Instantiate the application
    """
    assert app
