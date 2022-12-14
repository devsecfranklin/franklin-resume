import setuptools

# Package meta-data.
NAME = 'franklin-resume'
DESCRIPTION = 'Resume Application'
URL = 'https://github.com/devsecfranklin/franklin-resume'
EMAIL = 'devsecfranklin@duck.com'
AUTHOR = 'Franklin Diaz'
REQUIRES_PYTHON = '>=3.9.0'
VERSION = '0.3'

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

# Where the magic happens:
setuptools.setup(
    name=NAME,
    version=VERSION,
    description=DESCRIPTION,
    long_description=long_description,
    long_description_content_type='text/markdown',
    author=AUTHOR,
    author_email=EMAIL,
    python_requires=REQUIRES_PYTHON,
    url=URL,
    license='MIT',
)
