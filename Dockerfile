# syntax=docker/dockerfile:1

FROM golang:alpine AS builder

LABEL maintainer="Franklin Diaz <fdiaz@paloaltonetworks.com>"
LABEL org.opencontainers.image.source="https://github.com/devsecfranklin/lab-franklin"

WORKDIR /go
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV GOPRIVATE github.com/PaloAltoNetworks/*
ENV PATH /home/${USER}/bin:${GOROOT}/bin:/opt/google-cloud-sdk/bin:$PATH
ENV GOLANG_VERSION 1.16

# Packages
RUN apk add --no-cache \
        bash \
        tar \
        git \
        make \
        openssh \
        curl \
        gcc \
        doas \
        libc-dev

# Crossplane CLI
RUN curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | ash

# Terrascan
#RUN go get github.com/accurics/terrascan \
#        && chmod o+w ${GOPATH}/pkg/mod/github.com/accurics/terrascan* \
#        && cd ${GOPATH}/pkg/mod/github.com/accurics/terrascan* \
#        && CGO_ENABLED=0 GO111MODULE=on go build -o ${GOROOT}/bin/terrascan cmd/terrascan/main.go

HEALTHCHECK --interval=5m --timeout=3s \
  #CMD echo "Dont forget to do the thing."
  CMD curl -f http://0.0.0.0:8080/ || exit 1
