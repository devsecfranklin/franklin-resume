FROM python:3.9.1-buster
LABEL maintainer "Franklin Diaz <franklin@bitsmasher.net>"
ENV DEBIAN_FRONTEND noninteractive

ADD . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install Cython
RUN pip install -r python/requirements.txt
CMD ["python", "python/my_resume/my_resume.py"]
