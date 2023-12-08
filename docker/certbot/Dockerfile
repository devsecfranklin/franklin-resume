# syntax=docker/dockerfile:1

FROM python:3.12-slim-bullseye

LABEL maintainer="DE:AD:10:C5 <franklin@dead10c5.org>"
LABEL org.opencontainers.image.source=https://github.com/devsecfranklin/lab-franklin
LABEL org.opencontainers.image.description="Certbot Update container"
LABEL org.opencontainers.image.licenses=MIT

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1

ARG PASS
ENV MYPASS=${PASS}

RUN apt-get update && \
    apt-get install -y apt-utils wget curl certbot openssl

RUN pip install --upgrade pip ; \
  pip install pan-python;\ 
  pip install certbot-dns-cloudflare

COPY .cloudflare.ini ${WORKDIR}

RUN panxapi.py -h panorama1.dead10c5.org -l franklin:"${MYPASS}" -k >> ${WORKDIR}/.panrc

RUN  ls -la ${WORKDIR}

# cloudflare-credentials ${WORKDIR}/.cloudflare.ini -d panorama1.dead10c5.org --preferred-challenges dns-01
