import json
import logging
import logging.config
import os

import requests

logging.config.fileConfig(
    "logging.conf",
    defaults={"logfilename": "mmmbot.log"},
    disable_existing_loggers=False,
)

logger = logging.getLogger("hanson")


class Utils:
    """Discord specific commands."""

    def __init__(self):
        self.bot_data_folder = "/tmp/hanson"
        self.DISCORD_BOT_GUILD = os.getenv("DISCORD_BOT_GUILD")
        self.DISCORD_BOT_CHANNEL = os.getenv("DISCORD_BOT_CHANNEL")
        self.DISCORD_BOT_TOKEN = os.getenv("DISCORD_BOT_TOKEN")
        self.MASTODON_CLIENT_KEY = (os.getenv("MASTODON_CLIENT_KEY"),)
        self.MASTODON_CLIENT_SECRET = (os.getenv("MASTODON_CLIENT_SECRET"),)
        self.MASTODON_ACCESS_TOKEN = (os.getenv("MASTODON_ACCESS_TOKEN"),)
        self.MASTODON_API_BASE_URI = ("https://botsin.space/",)
        self.GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
        self.LIMIT = 10

    def make_folders(self):
        """Create the folders the bot will use"""
        if not os.path.exists(self.bot_data_folder):
            os.mkdir(self.bot_data_folder)
            logger.debug("Created folder: {}".format(self.bot_data_folder))
        else:
            logger.debug("Already exist folder: {}".format(self.bot_data_folder))

    def get_server_info(self):
        """Reusable server info function

        Returns:
            _type_: _description_
        """
        self.make_folders()

        headers = {"Authorization": "Bot {}".format(self.DISCORD_BOT_TOKEN)}
        base_URL = "https://discord.com/api/guilds/{}/members".format(
            self.DISCORD_BOT_GUILD
        )
        params = {"limit": self.LIMIT}
        r = requests.get(base_URL, headers=headers, params=params, timeout=10)

        # print(r.status_code)
        # print(r.text, "\n")
        # print(r.raise_for_status())
        # for obj in r.json():
        #    print(obj, "\n")
        # return r.text

        with open(self.bot_data_folder + "/serverinfo.txt", "w") as f:
            f.write(r.text)
        f.close()
        msg = "Server info written to disk."
        print(msg)
        logger.debug(msg)
        return msg
