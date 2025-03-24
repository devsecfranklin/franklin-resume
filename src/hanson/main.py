# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import asyncio
import logging
import os

import discord
from discord.ext import commands
from dotenv import load_dotenv

from cogs import (
    cog_discord,
    cog_error,
    cog_football,
    cog_mastodon,
    cog_music,
    cog_minecraft,
)

logger = logging.getLogger("hanson")


async def init_cogs(bot):
    """Loop through all cogs in our list and add them to our Bot"""
    logger.debug("Calling init_cogs()")

    try:
        await bot.add_cog(
            cog_discord.Disco(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: {cog_discord}")
        await asyncio.sleep(2)

        await bot.add_cog(
            cog_error.CommandErrorHandler(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: {cog_error}")
        await asyncio.sleep(2)

        await bot.add_cog(cog_football.Football(bot))
        print(f"Cog has been loaded: {cog_football}")
        await asyncio.sleep(2)

        await bot.add_cog(cog_mastodon.Masto(bot))
        print(f"Cog has been loaded: {cog_mastodon}")
        await asyncio.sleep(2)

        await bot.add_cog(cog_music.Music(bot))
        print(f"Cog has been loaded: {cog_music}")
        await asyncio.sleep(2)

        await bot.add_cog(cog_minecraft.Minecraft(bot))
        print(f"Cog has been loaded: {cog_minecraft}")
        await asyncio.sleep(2)

    except Exception as e:
        print(e)
        logger.error(f"There was an error: {e}")


load_dotenv(".envrc")  # Load our secret environment variables

# Guilds in Discord represent an isolated collection of users and channels,
# and are often referred to as "servers" in the UI.
intents = discord.Intents.default()
intents.message_content = True
intents.typing = False
intents.presences = False

bot = commands.Bot(command_prefix="%", intents=intents)
asyncio.run(init_cogs(bot))

token = os.getenv("DISCORD_BOT_TOKEN")
bot.run(f"{token}")
