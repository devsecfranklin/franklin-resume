import logging
import os
from configparser import ConfigParser

# import requests
from google.cloud import secretmanager

# from requests.packages.urllib3.exceptions import InsecureRequestWarning
# requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


class ConfigurationHelper:
    """Build the configuration from config.ini."""

    required_options = ["project_id", "secret_name", "label_name"]
    section = "required_options"

    def read_config(self, my_config_file):
        """Read in the configuration file."""
        config = ConfigParser()
        path = "/".join((os.path.abspath(__file__).replace("\\", "/")).split("/")[:-1])
        config.read(os.path.join(path, my_config_file))

        logger.info("Validate the user defined configuration.")
        logger.debug(config.sections())

        if not config.has_section(self.section):
            logger.error("Missing required section: %s", self.section)
            raise ValueError("Missing required section {}".format(self.section))

        for option in self.required_options:
            has_option = config.has_option(self.section, option)
            logger.debug("{}.{:<12}  : {}".format(self.section, option, has_option))
            if not config.has_option(self.section, option):
                logger.error("Missing required option: %s", option)
                raise ValueError("Missing required argument {}".format(option))

        logger.info("User defined configuration is formatted properly.")
        return config


class SecretHelper:
    """Handler for pulling secret from GCloud Secret Manager."""

    def get_secret(self, project_id, my_secret):
        """Pull the secret/token/password from the Secret Manager."""
        logger.info("Pull secret from Secret Manager for project_id %s", project_id)

        password = ""

        try:
            client = secretmanager.SecretManagerServiceClient()
            name = (
                "projects/"
                + str(project_id)
                + "/secrets/"
                + my_secret
                + "/versions/latest"
            )
            response = client.access_secret_version(name=name)
            password = response.payload.data.decode("UTF-8")
        except Exception as e:
            logger.info("SecretHelper.get_secret() :: failure pulling password: %s", e)
            return None  # This has to return none so we can try other Panorama.

        logger.info("Secret pulled successfully from GCP Secret Manager.")

        return password


"""
Authors:       Franklin D. <thedevilsvoice@protonmail.ch>

Description:

Usage:          (From top level of repo)
                python3 -m src/main.py

Requirements: src/requirements.txt

Python:       Version 3.9.x
"""
