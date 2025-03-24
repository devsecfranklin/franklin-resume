#!/usr/bin/env python

from setuptools import setup

with open("README.md", encoding='ascii') as file:
    long_description = file.read()

setup(
    name="hanson",
    version="0.0.2",
    description="A custom Discord bot with several useful "
    "integrations.",
    long_description=long_description,
    url="https://github.com/devsecfranklin/bot-hanson",
    author="Franklin D.",
    author_email="franklin@bitsmasher.net",
    license="MIT",
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.11",
    ],
    keywords="discord bot cog minecraft rcon mastodon",
    py_modules=[""],
    entry_points={},
)
