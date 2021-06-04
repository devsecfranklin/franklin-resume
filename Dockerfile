# syntax=docker/dockerfile:1

FROM python:3.9-buster

LABEL maintainer "Franklin Diaz <franklin@bitsmasher.net>"

# This is used for adding to the label of the docker image.
#ARG BUILD_DATE
#LABEL org.label-schema.build-date=$BUILD_DATE

ENV DEBIAN_FRONTEND noninteractive

ADD . /workspace/franklin-resume
WORKDIR /franklin-resume

RUN pip install Cython
RUN pip install -rrequirements.txt
CMD ["/usr/local/bin/python3", "src/my_resume.py"]
