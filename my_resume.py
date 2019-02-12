import subprocess
from flask import Flask, render_template

my_resume = Flask(__name__)

@my_resume.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin D. Resume')

if __name__ == '__main__':
  bashCommand = "make html"
  process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
  output, error = process.communicate()
  my_resume.run(debug=True)