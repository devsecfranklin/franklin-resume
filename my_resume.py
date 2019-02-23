import subprocess
from flask import Flask, Response, render_template
import codecs

my_resume = Flask(__name__)

@my_resume.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin D. Resume')

@my_resume.route('/download')
def download():
  file = codecs.open('/app/doc/my_resume.docx','r', encoding='utf-8', errors='ignore')
  returnfile = file.read()
  file.close()
  return Response(returnfile, mimetype="application/vnd.openxmlformats-officedocument.wordprocessingml.document", headers={"Content-disposition": "attachment; filename=my_resume.docx"})

@my_resume.errorhandler(404)
def page_not_found(e):
  # note that we set the 404 status explicitly
  return render_template('404.html'), 404

if __name__ == '__main__':
  bashCommand = "make html"
  process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
  output, error = process.communicate()
  my_resume.run(debug=True)
