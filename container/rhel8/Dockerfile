# syntax=docker/dockerfile:1

FROM registry.access.redhat.com/ubi8/ubi:latest

LABEL org.opencontainers.image.authors="franklin <fdiaz@paloaltonetworks.com>" \
      org.opencontainers.image.source="https://github.com/devsecfranklin/lab-franklin/container/rhel8" \
      org.opencontainers.image.description="customer project" \
      org.opencontainers.image.licenses=MIT

LABEL release="0.2"

USER 0

ENV APP_ROOT=/home/zjx1chw/workspace/customer
COPY . ${APP_ROOT}
WORKDIR ${APP_ROOT}

COPY container/rhel8/files/home/.gitconfig ${APP_ROOT}
COPY container/rhel8/files/home/.bash_profile ${APP_ROOT}
COPY container/rhel8/files/etc/motd /etc

ENV USER_NAME=zjx1chw \
    USER_UID=9001
ENV APP_HOME=${APP_ROOT}/src  PATH=$PATH:${APP_ROOT}/bin

#RUN mkdir -p ${APP_HOME}
RUN chmod -R u+x ${APP_ROOT}/bin && \
    useradd -l -u ${USER_UID} -r -g 0 -d ${APP_ROOT} -s /sbin/nologin -c "${USER_NAME} user" ${USER_NAME} && \
    chown -R ${USER_UID}:0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT}

ARG RHEL_USER
ENV RHEL_USER=$RHEL_USER
ARG RHEL_PASS
ENV RHEL_PASS=$RHEL_PASS
RUN subscription-manager register --username ${RHEL_USER} --password ${RHEL_PASS} \
  && subscription-manager refresh \
  && subscription-manager attach --auto

########## DEVELOPMENT TOOLS ##########
RUN yum -y install make git gnupg2 xmlstarlet \
    && yum clean all; \
    curl -sfL https://direnv.net/install.sh | bash; \
    cd /tmp && git clone https://git.zx2c4.com/password-store \
    && cd /tmp/password-store && make install; \
    dnf install -y python3.11 python3.11-pip; \
    yum update -y ca-certificates

########## Terraform ##########
RUN yum install -y yum-utils; \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo; \
    yum -y install terraform

# Update Cron and Email
#RUN dnf install -y crond; \
#  yum install -y postfix
#  chkconfig crond on

RUN cd ${APP_ROOT} \
  && make clean \
  && ${APP_ROOT}/bootstrap.sh \
  && make test

########## DOCUMENTATION ##########
# RUN wget https://github.com/jgm/pandoc/releases/latest -O /tmp/pandoc.tgz; \
#   tar zxvf /tmp/pandoc.tgz --strip-components 1 -C /usr/local/; \
#   bin/generate_docs.sh

# USER 9001
VOLUME ${APP_ROOT}/logs ${APP_ROOT}/data
