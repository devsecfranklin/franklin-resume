import os, subprocess
from flask import Flask, request, abort, jsonify, send_from_directory, Response, flash, render_template, session
import flask
import codecs

# support for local test env
debug = True

if 'S3_KEY' in os.environ:
  debug = False
  username = os.environ['S3_KEY'] 
  password = os.environ['S3_SECRET']
else:
  username = 'admin'
  password = 'admin'

DOWNLOADS = "/app/doc"

my_resume = Flask(__name__)

@my_resume.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin Diaz Resume')

@my_resume.route("/files")
def list_files():
  """Endpoint to list files on the server."""
  files = []
  for filename in os.listdir(DOWNLOADS):
    path = os.path.join(DOWNLOADS, filename)
    if os.path.isfile(path):
      files.append(filename)
  return jsonify(files)

@my_resume.route("/files/<path:path>")
def get_file(path):
  """Download a file."""
  return send_from_directory(DOWNLOADS, path, as_attachment=True)

@my_resume.errorhandler(404)
def page_not_found(e):
  if request.method == 'POST':
    if request.form['submit_button'] == 'Go Back to Resume':
      return render_template('index.html', title = 'Franklin Diaz Resume')
    else:
      pass # unknown
  elif request.method == 'GET':
    # note that we set the 404 status explicitly
    return render_template('404.html'), 404

if __name__ == '__main__':
  my_resume.secret_key = os.urandom(12)
  my_resume.run(host="0.0.0.0", debug=True)