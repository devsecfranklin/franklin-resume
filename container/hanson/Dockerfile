# syntax=docker/dockerfile:1

FROM python:3.13-slim-bullseye

LABEL maintainer="DE:AD:10:C5 <thedevilsvoice@dead10c5.org>"
LABEL org.opencontainers.image.source=https://github.com/devsecfranklin/lab-franklin
LABEL org.opencontainers.image.description="Social networking"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY src/hanson /app

RUN apt-get update && \
    apt-get install -y apt-utils wget curl

COPY src/hanson/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Expose the Docker container for the application to run on port 5000
EXPOSE 8082
# The command required to run the Dockerized application
CMD ["python", "/app/main.py"]
