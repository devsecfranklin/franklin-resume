"""config.py."""

import os

basedir = os.path.abspath(os.path.dirname(__file__))


class Config(object):
    """Config.

    Args:

        object (_type_): _description_
    """
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = os.environ["SECRET_KEY"]


class ProductionConfig(Config):
    """ProductionConfig.

    Args:

        Config (_type_): _description_
    """
    DEBUG = False


class StagingConfig(Config):
    """StagingConfig.

    Args:

        Config (_type_): _description_
    """
    DEVELOPMENT = True
    DEBUG = True


class DevelopmentConfig(Config):
    """DevelopmentConfig.

    Args:

        Config (_type_): _description_
    """
    DEVELOPMENT = True
    DEBUG = True


class TestingConfig(Config):
    """TestingConfig.

    Args:

        Config (_type_): _description_
    """
    TESTING = True
