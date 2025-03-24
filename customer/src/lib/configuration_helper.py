"""configuration_helper."""

# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf


class ConfigurationHelper:
    """Build the configuration from config.ini."""

    timeout = ""

    required_options = [
        "project_id",
        "username",
        "secret_name",
        "panorama_primary",
        "fw_username",
        "fw_secret_name",
        "fw_primary",
    ]
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
