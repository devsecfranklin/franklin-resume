# syntax=docker/dockerfile:1

FROM python:3.10.2-slim-bullseye

LABEL maintainer="Franklin Diaz <fdiaz@paloaltonetworks.com>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/lab-franklin"

WORKDIR /workspace/lab-franklin
ENV MY_DIR /workspace/lab-franklin
COPY . ${MY_DIR}

# Debian packages
ENV DEBIAN_FRONTEND noninteractive
RUN \
    apt update; \
    apt install gnupg2;\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367;\
    apt-get install -y dialog apt-utils; \
    apt-get install -y wget unzip make

HEALTHCHECK --interval=5m --timeout=3s \
  #CMD echo "Dont forget to do the thing."
  CMD curl -f http://0.0.0.0:8080/ || exit 1
  
