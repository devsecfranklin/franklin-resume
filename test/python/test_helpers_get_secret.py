"""Testing the GCP Cloudbot."""

from gcp.helpers import ConfigurationHelper, SecretHelper


def test_get_secret_pass():
    """Test Get Secret from Secret Store.

    (Test to Pass)
    """
    my_config = ConfigurationHelper()
    config = my_config.read_config("config.ini")
    project_id = int(config["required_options"]["project_id"])
    my_secret = SecretHelper()
    secret_name = config["required_options"]["secret_name"]

    test_secret = my_secret.get_secret(project_id, secret_name)
    assert test_secret, password


def test_get_secret_fail(caplog):
    """Test Get Secret from Secret Store.

    (Test to Fail) Bad Project
    """
    my_secret = SecretHelper()

    assert my_secret.get_secret("dupa-jaś", "dupa-jaś") is None
