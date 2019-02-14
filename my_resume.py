import subprocess
from flask import Flask, render_template

my_resume = Flask(__name__)

@my_resume.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin D. Resume')

@my_resume.route('/download')
def download():
  file = open('doc/my_resume.docx','r')
  returnfile = file.read().encode('latin-1')
  file.close()
  return Response(returnfile,
  	 mimetype="text/docx",
  	 headers={"Content-disposition": "attachment; filename=doc/my_resume.docx"})

if __name__ == '__main__':
  bashCommand = "make html"
  process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
  output, error = process.communicate()
  my_resume.run(debug=True)