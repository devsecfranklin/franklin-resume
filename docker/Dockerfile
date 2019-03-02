FROM python:3.7
ADD . /app
WORKDIR /app
#EXPOSE 8000

RUN pip install --upgrade pip
RUN pip install Cython
RUN pip install -r requirements/requirements.txt
CMD ["python", "my_resume/my_resume.py"]
