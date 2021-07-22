# syntax=docker/dockerfile:1

FROM python:3.9-buster

LABEL maintainer "Franklin Diaz <franklin@bitsmasher.net>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/franklin-resume"

WORKDIR /workspace
ENV MY_DIR /workspace
COPY . ${MY_DIR}

ENV DEBIAN_FRONTEND noninteractive

RUN \
  pip install Cython; \
  pip install -r${MY_DIR}/requirements.txt

CMD ["/usr/local/bin/python3", "${MY_DIR}/src/my_resume.py"]

