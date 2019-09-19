FROM python:3.6
ADD . /app
WORKDIR /app
#USER thedevilsvoice:thedevilsvoice

RUN pip install --upgrade pip
RUN pip install Cython
RUN pip install -r requirements/requirements.txt
RUN wget https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb
RUN dpkg -i /app/pandoc-2.7.3-1-amd64.deb
CMD ["python", "my_resume/my_resume.py"]
