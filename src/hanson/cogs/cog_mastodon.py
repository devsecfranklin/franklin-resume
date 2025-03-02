# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import datetime
import logging
import os
from random import randrange

# import pygraphviz as pgv  # sudo apt install libgraphviz-dev
import requests
from discord.ext import commands
from mastodon import Mastodon
from terraform import TerraformHelpers

from . import Utils

logger = logging.getLogger("hanson")


class Masto(commands.Cog):
    """Discord specific commands."""

    def __init__(self, bot):
        self.bot = bot
        self.MyUtils = Utils()

    @commands.Cog.listener()
    async def on_ready(self):
        logger.info(f"{self.__class__.__name__} Cog has been loaded")

    def mastodon_status_post(self, msg):
        m = Mastodon(
            client_id=self.MyUtils.MASTODON_CLIENT_KEY,
            client_secret=self.MASTODON_CLIENT_SECRET,
            access_token=self.MASTODON_ACCESS_TOKEN,
            api_base_url=self.MASTODON_API_BASE_URI,
        )

        post = m.status_post(msg)
        logger.debug(post)

    def mastodon_media_test(self, my_image):
        m = Mastodon(
            client_id=self.MyUtils.MASTODON_CLIENT_KEY,
            client_secret=self.MASTODON_CLIENT_SECRET,
            access_token=self.MASTODON_ACCESS_TOKEN,
            api_base_url=self.MASTODON_API_BASE_URI,
        )

        media = m.media_post(my_image, description="MMMBOP")
        # media = m.media_post(my_image, description="doomsday")
        post = m.status_post("posted by Hanson", media_ids=media)
        logger.debug(post)

    def mastodon_media(self, user, uri):
        m = Mastodon(
            client_id=self.MyUtils.MASTODON_CLIENT_KEY,
            client_secret=self.MASTODON_CLIENT_SECRET,
            access_token=self.MASTODON_ACCESS_TOKEN,
            api_base_url=self.MASTODON_API_BASE_URI,
        )

        img_data = requests.get(uri, timeout=10).content
        suffix = datetime.datetime.now().strftime("%y%m%d_%H%M%S")
        filename = "_".join(["image", suffix])
        local_img = "src/images/" + filename + ".jpg"
        with open(local_img, "wb") as handler:
            handler.write(img_data)

        media = m.media_post(local_img, description="MMMBOP", mime_type="image/jpeg")
        # media = m.media_post(my_image, description="doomsday")
        post = m.status_post(
            "{} posted image from Discord", format(user), media_ids=media
        )
        logger.debug(post)

    """
    def convert_dot_to_pgv(self, folder, tf_output):
        # Write the dot file to local filesystem. Return a pygraphviz object
        gv = pgv.AGraph(
            folder + "/temp-dot.dot", strict=False, directed=True
        )  # convert dot file to pygraphviz format
        # http://www.graphviz.org/doc/info/attrs.html
        gv.graph_attr.update(
            landscape="true", ranksep="0.1"
        )  # Graphviz graph keyword parameters
        gv.node_attr.update(color="red")
        gv.edge_attr.update(len="2.0", color="blue")
        return gv
    """

    @commands.command(
        name="testtoot",
        brief="(mod) print a test status message",
        help="(mod) print a test status message",
    )
    async def testtoot(self, ctx):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            self.mastodon_status_post("hello world!")
            await ctx.send("Sent test post to Mastodon.")
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")

    @commands.command(
        name="testimage",
        brief="(mod) post test image to Mastodon",
        help="(mod) post test image to Mastodon",
    )
    # @commands.has_role("Server Booster") # this works but how to catch the exception?
    async def testimage(self, ctx):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            self.mastodon_media_test("src/images/hanson.jpg")
            await ctx.send("Sent test image to Mastodon.")
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")

    @commands.command(
        name="image",
        brief="Post image to Mastodon from URI",
        help="Post image to Mastodon from URI",
    )
    # @commands.has_role("Server Booster") # this works but how to catch the exception?
    async def image(self, ctx, uri):
        user = ctx.message.author  # grab the user who sent the command
        # if "moderator" or "Server Booster" in [i.name.lower() for i in ctx.author.roles]:
        self.mastodon_media(user, uri)
        await ctx.send("Sending Image to mastodon from URI.")
        # else:
        #    await ctx.send("Nice try, nerd. Boost the server for access.")

    @commands.command(
        name="generate",
        brief="Generate digraph and post it to Mastodon",
        help="(Experimental) Generate digraph and post it to Mastodon",
    )
    # @commands.has_role("Server Booster") # this works but how to catch the exception?
    async def generate(self, ctx):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            folder = ""
            with open(self.MyUtils.bot_data_folder + "/tf-folders.txt", "w") as f:
                lines = [line.rstrip() for line in f]
                i = randrange(len(lines))
                folder = lines[i]
            await ctx.send("Using {} as the folder".format(folder))
            print("Using {} as the folder".format(folder))
            logger.debug("Using {} as the folder".format(folder))

            terraform = TerraformHelpers()
            tf_output = ""
            if terraform.check_init(folder):
                tf_output = terraform.collect_digraph_from_terraform(
                    folder
                )  # get digraph from tf plan
                try:
                    text_file = open(folder + "/temp-dot.dot", "w")
                    text_file.write(tf_output)
                    text_file.close()
                except Exception as e:
                    print("There was some error writing the graph dot file", e)
            else:
                print("The Terraform is old/broken.")
                await ctx.send("The Terraform is old/broken.")

            gv = self.convert_dot_to_pgv(
                folder, tf_output
            )  # write the terraform digraph to a dot file

            logger.debug("Generating PNG file...")
            gv.draw(
                folder + "/temp-dot.png", format="png", prog="dot"
            )  # make a nice picture in PNG format
            self.mastodon_media_test(folder + "/temp-dot.png")
            await ctx.send(
                "Your image was posted to {}, thanks for playing.".format(
                    "https://botsin.space/@hanson"
                )
            )
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")


"""
__author__     = 'devsecfranklin'
__version__    = '0.1'
__email__      = 'devsecfranklin@duck.com'
"""
