FROM python:3.7

ADD . /app

WORKDIR /app

EXPOSE 8000

RUN pip install -r requirements.txt
RUN pip install pandoc
ENTRYPOINT ["python", "my_resume.py"]
