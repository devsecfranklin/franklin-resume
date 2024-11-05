# syntax=docker/dockerfile:1

FROM node:22-alpine

LABEL maintainer="DE:AD:10:C5 <thedevilsvoice@dead10c5.org>"
LABEL org.opencontainers.image.source = "https://github.com/devsecfranklin/lab-franklin"
LABEL org.opencontainers.image.description="lab-franklin"
LABEL org.opencontainers.image.licenses=GPLv2

ENV NODE_ENV=production

COPY ["app.js", "package.json", "package-lock.json", "./"]

RUN npm install --production

COPY . .

ENTRYPOINT ["node", "app.js"]
