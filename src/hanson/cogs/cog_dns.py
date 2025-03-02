# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import logging
import os

from discord.ext import commands

logger = logging.getLogger("hanson")


class Music(commands.Cog):
    """Discord specific commands."""

    def __init__(self, bot):
        self.bot = bot
        self.guild_id = os.getenv("DISCORD_BOT_GUILD")
        self.bot_channel = os.getenv("DISCORD_BOT_CHANNEL")
        self.TOKEN = os.getenv("DISCORD_BOT_TOKEN")
        self.github_token = os.environ.get("GITHUB_TOKEN")

    @commands.Cog.listener()
    async def on_ready(self):
        """Loading message"""
        logger.info("Cog has been loaded: %s", self.__class__.__name__)
