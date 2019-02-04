FROM ubuntu:latest  
RUN apt-get update

RUN pip install -r requirements.txt
