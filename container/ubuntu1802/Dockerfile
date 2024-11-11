FROM ubuntu:18.02

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q \
    && apt-get upgrade -q -y \
    && apt-get install -y \
        build-essential \
        curl \
        git \
        libbz2-dev \
        libncurses5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        zlib1g-dev

# Install Docker
#RUN apt-get install docker.io -y

# VIM Text editor ~37MB
RUN apt-get install vim -y

# Nano Text editor ~1MB
RUN apt-get install nano

# tree Directory output ~1MB
RUN apt-get install tree && \
    apt-get install ncdu

# Ping ~2MB
RUN apt-get install iputils-ping -yq && \
    apt-get install fping

# Traceroute ~1MB
RUN apt-get install traceroute

# ifconfig, netstat ~1MB
RUN apt-get install net-tools

# TCPDump ~3MB
RUN apt-get install tcpdump -y

# Telnet ~1MB ... useful for port testing :)
RUN apt-get install telnet

# Netcat ~1MB
RUN apt-get install netcat -y

# NSLookup ~45MB
RUN apt-get install dnsutils -y

# sha256sum and md5sum ~1MB
RUN apt-get install hashalot

# My Trace Route ~28MB
RUN apt-get install mtr -y

# Speedtest ~1MB
RUN pip install speedtest-cli

# todos and fromdos to convert LF to CR/LF for Windows/Linux/Mac text compatibility ~2MB
RUN apt-get install tofrodos

# Screen ~1MB
RUN apt-get install screen -y

# Hping3 ~5MB
# Examples: http://0daysecurity.com/articles/hping3_examples.html
# Note: Docker seems to rate/limit/drop flood commands
# ENV fixes prompting in Ubuntu 18.04
# Removed Apr. 2020 as deprecated by NMap/NPing
#RUN apt-get install hping3 -y

# Lynx Web Browser ~8MB
RUN apt-get install lynx -y

# Slurm Network Usage ~1MB
# Example: slurm -i eth0
RUN apt-get install slurm -y

# NMon System Monitor ~2MB
RUN apt-get install nmon -y

# Disk Monitor ~3MB
# Example: Disk Queue size: iostat -x
RUN apt-get install sysstat -y

# iPerf3 ~2MB
RUN git -c http.sslVerify=false clone https://github.com/esnet/iperf.git && \
    cd iperf && \
    ./configure && make && make install && ldconfig && \
    cd / && rm -rf /iperf
