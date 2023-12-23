# syntax=docker/dockerfile:1 

FROM debian:12.4-slim

LABEL maintainer="DE:AD:10:C5 <thedevilsvoice@dead10c5.org>"
LABEL org.opencontainers.image.source=https://github.com/devsecfranklin/lab-franklin
LABEL org.opencontainers.image.description="Social networking"
LABEL org.opencontainers.image.licenses=MIT

EXPOSE 749 88/udp

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update
RUN apt-get -y install locales krb5-{admin-server,kdc}
RUN apt-get -y install vim 
RUN apt-get -qq clean

ENV REALM ${REALM:-DEAD10C5.ORG}
ENV SUPPORTED_ENCRYPTION_TYPES ${SUPPORTED_ENCRYPTION_TYPES:-aes256-cts-hmac-sha1-96:normal}
ENV KADMIN_PRINCIPAL ${KADMIN_PRINCIPAL:-kadmin/admin}
ENV KADMIN_PASSWORD ${KADMIN_PASSWORD:-adminpassword}

COPY init-script.sh /tmp/
CMD /tmp/init-script.sh

