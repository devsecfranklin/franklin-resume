import logging

import google.generativeai as palm

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()
logger.setLevel(logging.INFO)


class PalmApiUtil:
    """Functions for interacting with PaLM API."""

    def __init__(
        self,
        PALM_API_KEY=None,
    ):
        self.PALM_API_KEY = ""

    def palm(self, prompt):
        """Make call to PaLM API"""
        palm.configure(api_key=self.PALM_API_KEY)

        try:
            models = [
                m
                for m in palm.list_models()
                if "generateText" in m.supported_generation_methods
            ]
            model = models[0].name
            logger.info("Using model: {}".format(model))
            logger.info("Prompt: {}".format(prompt))
        except Exception as e:
            logger.error("Problem checking models: {}".format(e))

        completion = None

        try:
            completion = palm.generate_text(
                model="models/text-bison-001",
                prompt=prompt,
                max_output_tokens=800,  # The maximum length of the response
            )
            logger.info(completion.result)
        except Exception as e:
            logger.error("Problem generating text: {}".format(e))

        return completion.result


"""
Authors:       Franklin D. <franklin@dead10c5.org>

Description:

Usage:          (From top level of repo, but probably as GCP cloud function)
                python3 -m src/main.py

Requirements: src/requirements.txt

Python:       Version 3.9.x
"""
