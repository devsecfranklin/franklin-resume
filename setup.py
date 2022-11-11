import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="n0ctilucent",
    version="1.1",
    description="GCP Cloud Function, bot to manage GH PRs, etc.",
    author="Franklin D.",
    author_email="thedevilsvoice@protonmail.ch",
    url="https://github.com/DEAD10C5/bot-n0ctilucent/",
    python_requires=">=3.8",
    extras_require={"test": ["pytest"]},
)
