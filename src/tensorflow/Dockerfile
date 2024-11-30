# syntax=docker/dockerfile:1

FROM nvcr.io/nvidia/l4t-tensorflow:r32.6.1-tf2.5-py3

LABEL maintainer "Franklin Diaz <2730246+devsecfranklin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y && apt-get install -y python3-pip

#RUN DEBIAN_FRONTEND=noninteractive apt-get install libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran -y
#RUN DEBIAN_FRONTEND=noninteractive apt-get install python3 python-dev python3-dev build-essential libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev -yq

#COPY . .

#RUN python3 -m pip install -rrequirements.txt
