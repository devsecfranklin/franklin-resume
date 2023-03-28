import logging
import os
import pathlib
from pprint import pprint

import requests
from discord.ext import commands
from pygit2 import UserPass, clone_repository

from . import Utils

logger = logging.getLogger("hanson")


class Disco(commands.Cog):
    """Discord specific commands.
    # bot.help_command = help.MyHelp() # help command display overrides, not working yet
    """

    def __init__(self, bot):
        self.bot = bot
        self.MyUtils = Utils()

    @commands.Cog.listener()
    async def on_ready(self):
        logger.info(f"{self.__class__.__name__} Cog has been loaded")

    def check_user(self, username):
        my_gh_username = "devsecfranklin"
        url = f"https://api.github.com/users/" + username

        # create a re-usable session object with the user creds in-built
        gh_session = requests.Session()
        gh_session.auth = (my_gh_username, self.MyUtils.DISCORD_BOT_TOKEN)

        # get the list of repos belonging to me
        # repos = json.loads(gh_session.get(repos_url).text)
        user_data = requests.get(url, timeout=10).json()
        # pprint(user_data)
        return user_data

    @commands.command(
        name="ping",
        brief="(mod) Test network connectivity",
        help="(mod) Test network connectivity",
    )
    async def ping(self, ctx):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            await ctx.send("pong")
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")

    @commands.command(name="check", brief="Check github user", help="Check github user")
    async def check(self, ctx, username):
        user_data = self.check_user(username)
        if user_data:
            logger.debug(
                "Printing out the userdata to the channel:\n {}".format(str(user_data))
            )
            await ctx.send(user_data)
        else:
            logger.debug("Not sending userdata to the channel")
            await ctx.send("Not sure on that one chief")

    @commands.command(
        name="clone",
        brief="(Experimental) Clone a gitHub Repo",
        help="(Experimental) Clone a gitHub Repo",
    )
    async def clone(self, ctx, uri):
        if "moderator" or "Server Booster" in [
            i.name.lower() for i in ctx.author.roles
        ]:
            folder = uri.split("/")[-1]
            if not os.path.exists(self.MyUtils.bot_data_folder + "/repos"):
                os.mkdir(self.MyUtils.bot_data_folder + "/repos")
            repo_path = (
                self.MyUtils.bot_data_folder + "/repos/" + folder
            )  # must be a new, empty directory
            if not os.path.exists(repo_path):
                clone_repository(uri, repo_path)  # Clones a non-bare repository
                # repo = clone_repository(repo_url, repo_path, bare=True) # Clones a bare repository
                print("cloned {}".format(uri))
                logger.debug("Cloned: " + uri)
                await ctx.send("Cloned: " + uri)
            else:
                print("Already exists: {}".format(repo_path))
                await ctx.send("Already exists, nice: {}".format(repo_path))
            my_pathlib_obj_list = list(pathlib.Path(repo_path).glob("**/*.tf"))
            tf_folders = []
            for p in my_pathlib_obj_list:
                folder_w_tf = p.parents[0]
                tf_folders.append(folder_w_tf)
            mylist = list(dict.fromkeys(tf_folders))
            await ctx.send("Found folders with Terraform files: " + str(len(mylist)))
            with open(self.MyUtils.bot_data_folder + "/tf-folders.txt", "w") as f:
                for x in mylist:
                    f.write(str(x) + "\n")
            await ctx.send("Try the %generate command to post a graph.")
        else:
            await ctx.send("Nice try, nerd. Boost the server for access.")

    @commands.command(
        name="info",
        brief="Bot Info",
        help="Bot info",
    )
    async def info(self, ctx):
        if "hacker fam" in [i.name.lower() for i in ctx.author.roles]:
            await ctx.send("My mastodon page: https://botsin.space/@hanson")
        else:
            await ctx.send("You aint fam whats this we shit")

    @commands.command(
        name="serverinfo",
        brief="(mod) Server Info",
        help="(mod) Server info",
    )
    async def serverinfo(self, ctx):
        if "hacker fam" in [i.name.lower() for i in ctx.author.roles]:
            srv_info = self.MyUtils.get_server_info()
            await ctx.send(srv_info)
        else:
            await ctx.send("You aint fam whats this we shit")


"""
__author__     = 'devsecfranklin'
__version__    = '0.1'
__email__      = 'devsecfranklin@duck.com'
"""

"""from github import Github
import pygit2

# using username and password establish connection to github
g = Github(userName, password)
org = g.get_organization('yourOrgName')

#create the new repository
repo = org.create_repo(projectName, description = projectDescription )

#create some new files in the repo
repo.create_file("/README.md", "init commit", readmeText)

#Clone the newly created repo
repoClone = pygit2.clone_repository(repo.git_url, '/path/to/clone/to')

#put the files in the repository here

#Commit it
repoClone.remotes.set_url("origin", repo.clone_url)
index = repoClone.index
index.add_all()
index.write()
author = pygit2.Signature("your name", "your email")
commiter = pygit2.Signature("your name", "your email")
tree = index.write_tree()
oid = repoClone.create_commit('refs/heads/master', author, commiter, "init commit",tree,[repoClone.head.get_object().hex])
remote = repoClone.remotes["origin"]
credentials = pygit2.UserPass(userName, password)
remote.credentials = credentials

callbacks=pygit2.RemoteCallbacks(credentials=credentials)

remote.push(['refs/heads/master'],callbacks=callbacks)
        """
