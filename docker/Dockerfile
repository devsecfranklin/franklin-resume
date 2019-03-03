FROM python:3.6
ADD . /app
WORKDIR /app
USER thedevilsvoice:thedevilsvoice

RUN pip install --upgrade pip
RUN pip install Cython
RUN pip install -r requirements/requirements.txt
CMD ["python", "my_resume/my_resume.py"]
