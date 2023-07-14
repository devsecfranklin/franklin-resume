# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import unittest
import pytest


def test_myview(client):
    assert client.get("/").status_code == 200
