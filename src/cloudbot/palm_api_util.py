import logging

import google.generativeai as palm

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


class PalmApiUtil:
    """Functions for interacting with PaLM API."""

    PALM_API_KEY = ""

    def __init__(
        self,
        PALM_API_KEY=None,
    ):
        self.PALM_API_KEY = ""

    def palm(self, prompt):
        palm.configure(api_key=self.PALM_API_KEY)

        models = [
            m
            for m in palm.list_models()
            if "generateText" in m.supported_generation_methods
        ]
        model = models[0].name
        logger.debug("Using model: {}".format(model))
        logger.debug("Prompt: {}".format(prompt))

        completion = palm.generate_text(
            model=model,
            prompt=prompt,
            max_output_tokens=6000,  # The maximum length of the response
        )

        logger.debug(completion.result)

        return completion.result

    def improvements(self, prompt):
        """make recommendations based on pR contents"""
        pass

    def security(self, prompt):
        """Suggest enhancements to the PR based on the files being updated."""
        pass

    def tests(self, prompt):
        """Create test cases based on the PR contents"""
        pass


"""
Authors:       Franklin D. <franklin@dead10c5.org>

Description:

Usage:          (From top level of repo, but probably as GCP cloud function)
                python3 -m src/main.py

Requirements: src/requirements.txt

Python:       Version 3.9.x
"""
