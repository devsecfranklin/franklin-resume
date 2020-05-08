FROM python:3.8.1-buster
LABEL AUTHOR="franklin@bitsmasher.net"
ENV DEBIAN_FRONTEND noninteractive

ADD . /app
WORKDIR /app

RUN pip install --upgrade pip
RUN pip install Cython
RUN pip install -r requirements/requirements.txt
RUN wget https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb
RUN dpkg -i /app/pandoc-2.7.3-1-amd64.deb
CMD ["python", "my_resume/my_resume.py"]
