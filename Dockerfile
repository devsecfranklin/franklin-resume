# syntax=docker/dockerfile:1

FROM python:3.10-slim-bullseye

LABEL maintainer "Franklin Diaz <2730246+devsecfranklin@users.noreply.github.com>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/franklin-resume"

WORKDIR /workspace
ENV MY_DIR /workspace
COPY . ${MY_DIR}

ENV DEBIAN_FRONTEND noninteractive

RUN \
  pip install --upgrade pip && \
  pip install Cython && \
  pip install -r${MY_DIR}/requirements.txt && \
  apt update && \
  apt install librust-gobject-sys-dev libpango1.0-dev

CMD ["/usr/local/bin/python3", "src/my_resume.py"]
