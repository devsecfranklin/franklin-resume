import subprocess
from flask import Flask, Response, render_template
import codecs

my_resume = Flask(__name__,static_folder='doc')

@my_resume.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin D. Resume')

@my_resume.route('/doc/<path:filename>', methods=['GET', 'POST'])
def download(filename):
  return send_from_directory(directory='doc', filename=filename)

@my_resume.errorhandler(404)
def page_not_found(e):
  # note that we set the 404 status explicitly
  return render_template('404.html'), 404

if __name__ == '__main__':
  bashCommand = "make html"
  process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
  output, error = process.communicate()
  my_resume.run(debug=True)
