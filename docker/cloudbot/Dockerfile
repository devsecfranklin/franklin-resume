# syntax=docker/dockerfile:1

FROM node:7

LABEL maintainer="Franklin D <franklin@bitsmasher.net>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/lab-franklin"

ADD app.js /app.js

ENTRYPOINT ["node", "app.js"]