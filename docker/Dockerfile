#FROM python:3.6
FROM debian:buster
ADD . /app
WORKDIR /app
#USER thedevilsvoice:thedevilsvoice

RUN apt update && apt install -y python3-pip pandoc
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install Cython
RUN python3 -m pip install -r requirements/requirements.txt
CMD ["python3", "my_resume/my_resume.py"]
