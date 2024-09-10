"""setup.py."""
import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="lab-franklin",
    version="0.8",
    description="Lab Stuff",
    author="Franklin D.",
    author_email="franklin@dead10c5.org",
    url="https://github.com/devvsecfranklin/lab-franklin/",
    python_requires=">=3.9",
    extras_require={"test": ["pytest"]},
)
