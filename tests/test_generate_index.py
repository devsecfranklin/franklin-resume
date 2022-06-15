import unittest
import pytest


def test_myview(client):
    assert client.get("/").status_code == 200

"""my_resume application

  Test like so: python3 -m pytest tests/
  :copyright:  © 2021 by Franklin Diaz
  :license: MIT
"""


def test_myview(client):
    assert client.get("/").status_code == 200
