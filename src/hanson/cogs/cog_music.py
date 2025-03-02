# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import logging
import os
import re
from pathlib import Path
from random import randrange

import discord
from discord import FFmpegPCMAudio
from discord.ext import commands

from . import Utils

logger = logging.getLogger("hanson")


class Music(commands.Cog):
    """Discord specific commands."""

    def __init__(self, bot):
        self.bot = bot
        self.MyUtils = Utils()
        self.music_folder = "/mnt/storage1/Music"
        self.FFMPEG_OPTIONS = {
            "options": "-vn",
        }
        self.YDL_OPTIONS = {
            "before_options": "-reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5",
            "format": "bestaudio/best",
            "noplaylist": "True",
        }

    @commands.Cog.listener()
    async def on_ready(self):
        logger.info(f"{self.__class__.__name__} Cog has been loaded")

    def is_connected(self):
        """Check if the bot is already in a Voice Channel

        Args:
            ctx (_type_): _description_

        Returns:
            bool: True if there is a chan and bot is connected.
        """
        voice_client = discord.utils.get(
            self.bot.voice_clients, guild=self.MyUtils.DISCORD_BOT_GUILD
        )
        logger.debug(f"Checking bot VC connection status.")
        return voice_client and voice_client.is_connected()

    async def my_output(self, ctx, msg):
        """_summary_

        Args:
            ctx (_type_): _description_
            msg (_type_): _description_
        """
        await ctx.send(msg)
        logger.debug(msg)
        print(msg)

    @commands.command(
        name="indexmusic",
        brief="(Experimental) Index music library",
        help="(Experimental) Index music library",
    )
    async def indexmusic(self, ctx):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            music_index = self.MyUtils.bot_data_folder + "/music_index.txt"
            if os.path.exists(music_index):
                await self.my_output(ctx, "Deleting file {}".format(music_index))
                os.remove(music_index)
            for path in Path(self.music_folder).rglob("*.mp3"):
                with open(music_index, "a") as f:
                    f.write(str(path.relative_to(path.parent.parent.parent)) + "\n")
            await self.my_output(ctx, "OK updating the music index file.")
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")

    @indexmusic.error
    async def indexmusic_error(self, ctx, error):
        await ctx.send("There was an error indexing music")
        if isinstance(error, commands.MissingRequiredArgument):
            await ctx.send("Missing Required Argument")
        elif isinstance(error, commands.errors.CommandInvokeError):
            await ctx.send(
                "Command raised an exception: AttributeError: 'PosixPath' object has no attribute"
            )
        else:
            raise error

    @commands.command(
        name="artist",
        brief="Find artist in music library",
    )
    async def artist(self, ctx, artist):
        """Search by Artist

        Should make a nice list and give the user to play one
        song at random or cycle through the results. The list
        name will be saved based on user ID.

        Args:
            ctx (_type_): _description_
            artist (_type_): _description_
        """
        search_result = []
        msg = "Searching music for {}".format(artist.lower())
        logger.debug(msg)

        if os.path.isfile(self.MyUtils.bot_data_folder + "/music_index.txt"):
            with open(self.MyUtils.bot_data_folder + "/music_index.txt", "r") as f:
                for line in f:
                    if len(line) == 0:
                        break  # happens at end of file, then stop loop
                    if artist.lower() in line.lower():
                        msg = "Found: {}".format(line)
                        search_result.append(line)
                        logger.debug(msg)
                if len(search_result) > 0:
                    msg = "found {} results.".format(len(search_result))
                else:
                    msg = "No results found. try again."
                await ctx.send(msg)
                logger.debug(msg)
                print(msg)
            await self.rand(ctx, search_result)
        else:
            await ctx.send("Could not search. Try indexing the music.")

    @artist.error
    async def artist_error(self, ctx, error):
        await ctx.send("There was an error with your search")
        if isinstance(error, commands.MissingRequiredArgument):
            await ctx.send("Dude wheres my band name?")
        else:
            raise error

    @commands.command(
        name="jv",
        brief="(Experimental) Join a voice channel.",
    )
    async def jv(self, ctx):
        channel = ctx.author.voice.channel
        voice = None

        for vc in self.bot.voice_clients:
            if self.MyUtils.DISCORD_BOT_GUILD == ctx.guild:
                voice = vc

        if not channel:
            await ctx.send("Not in a voice channel.")
            logger.debug(f"Not in a voice channel.")
            return

        if voice and voice.is_connected():
            vc = await voice.move_to(channel)
        elif voice == channel:
            return
        else:
            vc = await channel.connect()
        return vc

    @commands.command(
        name="lv",
        brief="Leave the voice channel",
    )
    async def leave(self, ctx):
        """_summary_

        Args:
            ctx (_type_): _description_
        """
        voice_client = ctx.message.guild.voice_client
        try:
            if voice_client.is_connected():
                await voice_client.disconnect()
            else:
                await ctx.send("The bot is not connected to a voice channel.")
        except Exception as e:
            print(e)
            logger.error("There was an error during a leave command: {}".format(e))

    @commands.command(
        name="ta",
        brief="(mod) Test audio in the voice channel",
        pass_context=True,
    )
    async def ta(self, ctx):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            user = ctx.message.author  # grab the user who sent the command
            channel = ctx.author.voice.channel
            vc = None

            if channel != None:  # author must be in VC
                logger.debug("User {} is in channel: {}".format(user, channel.name))
                if not self.is_connected(ctx):
                    vc = await channel.connect()
                    # vc = self.jv(ctx)
                async with ctx.typing():
                    await ctx.send("Now playing: {}".format("src/music/vuvuzela.mp3"))
                vc.play(
                    discord.FFmpegOpusAudio(
                        executable="ffmpeg", source="src/music/vuvuzela.mp3"
                    )
                )
            else:
                msg = "User is not in a channel."
                await ctx.send(msg)
                logger.debug(msg)
                print(msg)
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")

    @commands.command(
        name="rand",
        brief="Plays a random song",
        pass_context=True,
    )
    async def rand(self, ctx, mylist):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            user = ctx.message.author  # grab the user who sent the command
            channel = ctx.author.voice.channel
            vc = None

            lines = [line.rstrip() for line in mylist]
            i = randrange(len(lines))
            song = self.music_folder + "/" + lines[i]
            await self.my_output(ctx, "Found {} song names".format(i))
            await self.my_output(ctx, "Now playing song: {}".format(song))

            if channel != None:  # author must be in VC
                logger.debug("User {} is in channel: {}".format(user, channel.name))
                # if not self.is_connected(ctx):
                vc = await channel.connect()
                # vc = self.jv(ctx)
                async with ctx.typing():
                    await ctx.send("Now playing: {}".format(song))
                vc.play(
                    discord.FFmpegPCMAudio(
                        executable="ffmpeg",
                        source=song,
                        **self.FFMPEG_OPTIONS,
                    )
                )
            else:
                msg = "User is not in a channel."
                await ctx.send(msg)
                logger.debug(msg)
                print(msg)


"""
__author__     = 'devsecfranklin'
__version__    = '0.1'
__email__      = 'devsecfranklin@duck.com'
"""
