# syntax=docker/dockerfile:1

FROM python:3.11.4-slim-buster

LABEL maintainer="DE:AD:10:C5 <thedevilsvoice@dead10c5.org>"
LABEL org.opencontainers.image.source = "https://github.com/devsecfranklin/lab-franklin"
LABEL org.opencontainers.image.description="lab-franklin"
LABEL org.opencontainers.image.licenses=GPLv2

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
