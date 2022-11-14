# syntax=docker/dockerfile:1

FROM node:12.22.12

LABEL maintainer="Franklin D <franklin@bitsmasher.net>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/lab-franklin"

ENV NODE_ENV=production

COPY ["app.js", "package.json", "package-lock.json", "./"]

RUN npm install --production

COPY . .

ENTRYPOINT ["node", "app.js"]