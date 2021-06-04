# -*- coding: utf-8 -*-

"""
  my_resume application
  
  Test like so: python3 -m pytest tests/
  :copyright: (c) by Franklin Diaz
  :license: MIT
"""

# from flask import json, jsonify


def test_files(client):
    response = client.get("/files/")
    assert client.get("/files").status_code == 200
    # assert client.get(response.json, dict(success=True))
