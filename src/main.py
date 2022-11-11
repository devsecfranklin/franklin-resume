import logging

from flask import Flask, request
from github import Github

import github_util
import helpers

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

    """Get the Github token from Secret Manager"""
    my_gh_token = helpers.SecretHelper()
    token = my_gh_token.get_secret(project_id, secret_name)

    """Instantiate a GH object."""
    #logger.info("We get secret: {}".format(token))
    g = Github(token)
    my_gh_helper = github_util.GithubHelper()
    logger.info("Instantiate GH object with label {}".format(label_name))

    request_json = request.get_json()  # Receive and validate JSON requst.

    if request.args and "message" in request.args:
        logger.info("Please call again with msg in JSON format.")
        return request.args.get("message")  # Handle a non-JSON message

    if request_json and "message" in request_json:
        logger.info("Received JSON message: %s", str(request_json["message"]))

        my_gh_helper.check_json_fields(request_json)
        my_result = my_gh_helper.check_pr_label(
            g, label_name
        )  # add label to the PR if missing

        my_gh_helper.check_pr_for_files(g)
        my_gh_helper.check_comment_for_string(g, "@n0ctilucent")

        if my_result is False:
            logger.info("Adding comment to the commit.")
            my_gh_helper.add_commit_comment(
                g, "Hello friend. I will help you manage your pull request."
            )
            # my_gh_helper.assign_pr(g)

        else:
            logger.info("This PR already has the %s label on it.", label_name)

        return request_json["message"]
    else:
        return f"No JSON message from you."


if __name__ == "__main__":
    app = Flask(__name__)
    app.route("/")(lambda: main(request))
    app.run()


"""
Authors:       Franklin D. <thedevilsvoice@protonmail.ch>

Description:

Usage:          (From top level of repo)
                python3 -m src/main.py

Requirements: src/requirements.txt

Python:       Version 3.9.x
"""
