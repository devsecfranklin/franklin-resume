import unittest
import pytest


from flask import request
from werkzeug.datastructures import ImmutableMultiDict


def test_404(client):
    """See if we get a 404."""
    request.form = ImmutableMultiDict([("submit_button", "Go Back to Resume")])
    response = client.get("/garbage")
    assert response.status_code == 404

"""my_resume application

  Test like so: python3 -m pytest tests/
  :copyright:  © 2021 by Franklin Diaz
  :license: MIT
"""