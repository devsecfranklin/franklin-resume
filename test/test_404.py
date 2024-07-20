# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import unittest
import pytest


from flask import request
from werkzeug.datastructures import ImmutableMultiDict


def test_404(client):
    """See if we get a 404."""
    request.form = ImmutableMultiDict([("submit_button", "Go Back to Resume")])
    response = client.get("/garbage.html")
    assert response.status_code == 404
