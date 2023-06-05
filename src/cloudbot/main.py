import logging

import requests
from flask import Flask, request
from github import Github

import github_util
import helpers
import palm_api_util

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def main(request):
    """We put the "fun" in function."""
    logger.info("Started cloudbot")

    """Load in the Configuration"""
    my_config = helpers.ConfigurationHelper()
    config = my_config.read_config("config.ini")

    project_id = config["required_options"]["project_id"]
    secret_name = config["required_options"]["secret_name"]
    label_name = config["required_options"]["label_name"]

    my_secret_helper = (
        helpers.SecretHelper()
    )  # Get the Github token from Secret Manager
    token = my_secret_helper.get_secret(project_id, secret_name)
    # logger.info("We get secret: {}".format(token))

    g = Github(token)  # Instantiate a GH object.
    my_gh_helper = github_util.GithubHelper()
    logger.debug("Instantiate GH object with label {}".format(label_name))

    """Instantiate a palm object.
    palm_api_key = my_secret_helper.get_secret(project_id, palm_api_key)
    my_palm_util = palm_api_util.PalmApiUtil(palm_api_key)
    logger.info("Instantiate PaLM Object")
    """

    request_json = request.get_json()  # Receive and validate JSON requst.

    if request_json and "message" in request_json:
        logger.info("Received JSON message: %s", str(request_json["message"]))

        my_gh_helper.check_json_fields(request_json)
        my_result = my_gh_helper.check_pr_label(
            g, label_name
        )  # add label to the PR if missing

        if my_result is False:
            logger.info("Adding help to the commit.")
            help_text = """
            Hello {}, here are commands you can use with this PR:
            
            @tests - suggest test cases
            @improvements - suggest code optimization
            
            """.format(
                github_util.user
            )

            my_gh_helper.add_commit_comment(g, help_text)
            my_gh_helper.assign_pr(g)

        else:
            logger.info("This PR already has the %s label on it.", label_name)
            # my_gh_helper.check_pr_for_files(g)
            my_gh_helper.check_comment_for_string(g, "@n0ctilucent")
            my_gh_helper.check_comment_for_string(g, "@tests")
            my_gh_helper.check_comment_for_string(g, "@prompt")

        """
        # this is to post to GKE
        url = "http://10.11.0.109"
        cloudbot_response = requests.post(url, json=request_json, timeout=10)
        logger.info(str(cloudbot_response))
        """
        return request_json["message"]
        logger.info("success!")
    elif request.args and "message" in request.args:  # message not JSON
        logger.info("Please call again with msg in JSON format.")
        return request.args.get("message")  # Handle a non-JSON message
    else:  # not sure what they sent
        logger.info("unknown message: {}".format(request.args.get("message")))
        return f"No JSON message from you."


if __name__ == "__main__":
    app = Flask(__name__)
    app.route("/")(lambda: main(request))
    app.run()


"""
Authors:       Franklin D. <franklin@dead10c5.org>

Description:

Usage:          (From top level of repo)
                python3 -m src/main.py

Requirements: src/requirements.txt

Python:       Version 3.9.x
"""
