# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import logging
import os
from mcstatus import JavaServer

from discord.ext import commands

logger = logging.getLogger("hanson")


class Music(commands.Cog):
    """Discord specific commands."""

    def __init__(self, bot):
        self.bot = bot
        self.guild_id = os.getenv("DISCORD_BOT_GUILD")
        self.bot_channel = os.getenv("DISCORD_BOT_CHANNEL")
        self.token = os.getenv("DISCORD_BOT_TOKEN")
        self.github_token = os.environ.get("GITHUB_TOKEN")
        self.server = JavaServer.lookup("127.0.0.1:25565")

    @commands.Cog.listener()
    async def on_ready(self):
        """Loading message"""
        logger.info("Cog has been loaded: %s", self.__class__.__name__)

    @commands.command(
        name="mcstatus",
        brief="Get the MC server status",
        help="Get the MC server status",
    )
    async def mcstatus(self, ctx):
        """mcstatus

        Args:
            ctx (_type_): _description_

        # 'status' is supported by all Minecraft servers that are version 1.7 or higher.
        # Don't expect the player list to always be complete, because many servers run
        # plugins that hide this information or limit the number of players returned or even
        # alter this list to contain fake players for purposes of having a custom message here.
        """
        if ("moderator" or "Server Booster") in [
            i.name.lower() for i in ctx.author.roles
        ]:
            status = self.server.status()
            print(
                f"The server has {status.players.online} player(s) online and replied in {status.latency} ms"
            )
        else:
            await ctx.send("Nice try, nerd. Do you even play Minecraft?")

    @commands.command(
        name="mcping",
        brief="Get the MC server latency",
        help="Get the MC server latency",
    )
    async def mcping(self, ctx):
        """_summary_

        Args:
            ctx (_type_): _description_

        # 'ping' is supported by all Minecraft servers that are version 1.7 or higher.
        # It is included in a 'status' call, but is also exposed separate if you do not require the additional info.
        """

        latency = self.server.ping()
        print(f"The server replied in {latency} ms")

    @commands.command(
        name="mcquery", brief="Get the MC server query", help="Get the MC server query"
    )
    async def mcquery(self, ctx):
        """_summary_

        Args:
            ctx (_type_): _description_

        # 'query' has to be enabled in a server's server.properties file!
        # It may give more information than a ping, such as a full player list or mod information.
        """

        query = self.server.query()
        print(
            f"The server has the following players online: {', '.join(query.players.names)}"
        )
