# syntax=docker/dockerfile:1

FROM python:3.11.1-slim-buster
LABEL maintainer="Franklin D. <thedevilsvoice@protonmail.ch>"
LABEL org.opencontainers.image.source="https://github.com/DEAD10C5/bot-cloudbot"
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONPATH=/usr/local/lib/python3.9.6/site-packages
WORKDIR /workspace
ENV MY_DIR /workspace
RUN \
    apt update; \
    apt install gnupg2;\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367;\
    apt install -y dialog apt-utils
RUN \
  python3 -m pip install -rsrc/requirements.txt
CMD ["python3", "src/main.py"]
