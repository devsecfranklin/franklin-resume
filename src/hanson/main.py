import asyncio
import logging
import os

import discord
from discord.ext import commands
from dotenv import load_dotenv

from cogs import cog_discord, cog_error, cog_football, cog_mastodon, cog_music

logger = logging.getLogger("hanson")


async def init_cogs(bot):
    """Loop through all cogs in our list and add them to our Bot"""
    logger.debug("Calling init_cogs()")

    try:
        await bot.add_cog(
            cog_discord.Disco(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: cog_discord")
        await asyncio.sleep(2)

        await bot.add_cog(
            cog_error.CommandErrorHandler(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: cog_error")
        await asyncio.sleep(2)
        
        await bot.add_cog(
            cog_football.Football(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: cog_football")
        await asyncio.sleep(2)
        
        await bot.add_cog(
            cog_mastodon.Masto(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: cog_mastodon")
        await asyncio.sleep(2)
        
        await bot.add_cog(
            cog_music.Music(bot)
        )  # add_cog is a coroutine and should be awaited.
        print(f"Cog has been loaded: cog_music")
        await asyncio.sleep(2)

    except Exception as e:
        print(e)
        logger.error("There was an error: {}".format(e))


load_dotenv(".envrc")  # Load our secret environment variables
TOKEN = os.getenv("DISCORD_BOT_TOKEN")
# Guilds in Discord represent an isolated collection of users and channels, and are often referred to as "servers" in the UI.
intents = discord.Intents.default()
intents.message_content = True
intents.typing = False
intents.presences = False

bot = commands.Bot(command_prefix="%", intents=intents)
asyncio.run(init_cogs(bot))


bot.run(TOKEN)


"""
__author__     = 'devsecfranklin'
__version__    = '0.1'
__email__      = 'devsecfranklin@duck.com'
"""
