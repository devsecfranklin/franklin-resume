# syntax=docker/dockerfile:1

FROM python:3.13-bullseye

LABEL org.opencontainers.image.authors="Franklin <franklin@dead10c5.org>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/franklin-resume"
LABEL org.opencontainers.image.description="Resume as Code (RaC)"
LABEL org.opencontainers.image.licenses=MIT

RUN mkdir -p /home/franklin/workspace
WORKDIR /home/franklin/workspace
ENV MY_DIR /home/franklin/workspace
COPY . ${MY_DIR}

COPY docker/python3/files/bashrc /workspaces/franklin-resume/.bashrc

ENV DEBIAN_FRONTEND noninteractive

RUN \
  pip install --upgrade pip && \
  pip install Cython && \
  pip install -r${MY_DIR}/src/requirements.txt && \
  apt update && \
  apt install -y librust-gobject-sys-dev libpango1.0-dev

CMD ["/usr/local/bin/python3", "src/my_resume.py"]
