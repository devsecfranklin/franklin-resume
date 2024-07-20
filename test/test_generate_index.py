# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import unittest
import pytest


def test_myview(client):
    """Check to see what the return code is from flask/Heroku

    This will return a 302 on local dev env, need to run in container?

    Args:
        client (_type_): _description_
    """
    assert client.get("/").status_code == 200
