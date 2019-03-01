from setuptools import setup
 
setup(name='franklin-resume',
      version='0.1',
      description='Resume Application',
      author='franklin diaz',
      author_email='frank378@gmail.com',
      url='https://franklin-resume.herokuapp.com/',
     install_requires=['flask','flask-login','sqlalchemy','flask-sqlalchemy', 'gunicorn', 'pandoc'],
     )
