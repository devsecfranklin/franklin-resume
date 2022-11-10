"""Testing the GCP Tagging Project."""

import pytest
from gcp.helpers import ConfigurationHelper


def test_parse_args_pass(caplog):
    """Test Argument Parser function.

    (Test to pass)
    """
    my_config = ConfigurationHelper()
    config = my_config.read_config("config.ini")
    assert "User defined configuration is formatted properly." in caplog.text
    print(config)  # do this to supress lint error
