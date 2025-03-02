# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import datetime
import json
import logging
import os
from pprint import pprint

import requests
from discord.ext import commands

logger = logging.getLogger("hanson")


class Football(commands.Cog):
    """Discord specific commands."""

    def __init__(self, bot):
        self.bot = bot
        self.guild_id = os.getenv("DISCORD_BOT_GUILD")
        self.bot_channel = os.getenv("DISCORD_BOT_CHANNEL")
        self.TOKEN = os.getenv("DISCORD_BOT_TOKEN")
        self.github_token = os.environ.get("GITHUB_TOKEN")
        self.api_key = os.environ.get("X_RAPID_API_KEY")

        self.headers = {
            "X-RapidAPI-Key": self.api_key,
            "X-RapidAPI-Host": "rugby-live-data.p.rapidapi.com",
        }

    def validate_date(self, mydate):
        """_summary_

        Args:
            mydate (_type_): _description_

        Raises:
            ValueError: _description_

        Returns:
            _type_: _description_
        """
        success = False
        error_text = "Incorrect data format, should be YYYY-MM-DD"
        try:
            datetime.date.fromisoformat(mydate)
            success = True
        except ValueError:
            logger.error(error_text)
            raise ValueError(error_text)
        return success

    @commands.Cog.listener()
    async def on_ready(self):
        logger.info(f"{self.__class__.__name__} Cog has been loaded")

    @commands.command(
        name="date",
        brief="Results by Date",
        help="Results by Date",
    )
    async def team(self, ctx, mydate):
        url = "https://rugby-live-data.p.rapidapi.com/fixtures-by-date/" + mydate
        valid = self.validate_date(mydate)

        if valid:
            response = requests.request("GET", url, headers=self.headers)
            pprint(response.text)
            jdata = json.loads(response.text)
            for r in jdata:
                if r.get("comp_name") == "Six Nations":
                    print(r)
                    await ctx.send(r)
        else:
            await ctx.send("Incorrect data format, should be YYYY-MM-DD")


"""
__author__     = 'devsecfranklin'
__version__    = '0.1'
__email__      = 'devsecfranklin@duck.com'
"""
