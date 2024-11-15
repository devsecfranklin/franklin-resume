# syntax=docker/dockerfile:1

FROM sanketlab2021/freebsd

LABEL maintainer="DE:AD:10:C5 <thedevilsvoice@dead10c5.org>"
LABEL org.opencontainers.image.source = "https://github.com/DEAD10C5/freebsd-build-env"
LABEL org.opencontainers.image.description="DE:AD:10:C5 Free BSD Build Env"
LABEL org.opencontainers.image.licenses=GPLv2


#RUN git clone https://git.FreeBSD.org/ports.git /usr/ports
# RUN git -C /usr/ports pull # update ports

RUN \
  addgroup --gid 9001 engr && \
  adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/dead10c5" \
    --ingroup "engr" \
    --uid "1000" \
    "dead10c5"

WORKDIR /home/dead10c5
COPY . /home/dead10c5
RUN chown -R dead10c5:engr /home/dead10c5
