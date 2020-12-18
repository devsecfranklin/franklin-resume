"""
    my_resume application

    :copyright: (c) by Franklin Diaz
    :license: MIT
"""
# -*- coding: utf-8 -*-

import os

#import flask
from flask import Flask
from flask import jsonify
from flask import render_template
from flask import request
from flask import send_from_directory

#from flask import url_for
from flask_weasyprint import HTML, render_pdf

CURR_DIR = os.path.dirname(os.path.realpath(__file__))
DOWNLOADS = CURR_DIR + "/doc"

app = Flask(__name__)

"""
Move app setup tasks into create_app
so we can reference from test harness
"""


def create_app(debug):
  """need docstring"""
  app.debug = debug
  app.secret_key = os.urandom(12)
  return app


@app.route('/')
def render_static():
  """needs docstring"""
  return render_template('index.html', title='Franklin Diaz Resume')


@app.route("/files")
def list_files():
  """Endpoint to list files on the server."""
  files = []
  for filename in os.listdir(DOWNLOADS):
    path = os.path.join(DOWNLOADS, filename)
    if os.path.isfile(path):
      files.append(filename)
  return jsonify(files)


@app.route("/files/<path:path>")
def get_file(path):
  """Download a file."""
  return send_from_directory(DOWNLOADS, path, as_attachment=True)


@app.route('/franklin_resume.pdf')
def build_pdf():
  """needs a docstring"""
  html = render_template('index.html')
  return render_pdf(HTML(string=html))


@app.errorhandler(404)
def page_not_found(my_err):
  """needs a docstring"""
  if request.method == 'POST':
    if request.form['submit_button'] == 'Go Back to Resume':
      return render_template('index.html', title='Franklin Diaz Resume')
  elif request.method == 'GET':
    # note that we set the 404 status explicitly
    return render_template('404.html'), 404
  else:
    pass
  return my_err


if __name__ == '__main__':
  create_app(debug=True)
  app.run(host="0.0.0.0")
