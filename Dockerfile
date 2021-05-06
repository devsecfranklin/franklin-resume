# syntax=docker/dockerfile:1

FROM python:3.9.5-buster

LABEL maintainer "Franklin Diaz <franklin@bitsmasher.net>"

# This is used for adding to the label of the docker image.
ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE

ENV DEBIAN_FRONTEND noninteractive

ADD . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install Cython
RUN pip install -r python/requirements.txt
CMD ["/usr/local/bin/python3", "python/my_resume/my_resume.py"]
