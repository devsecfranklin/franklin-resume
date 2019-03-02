# -*- coding: utf-8 -*-
"""
    my_resume application

    :copyright: (c) by Franklin Diaz
    :license: MIT
"""
import os, subprocess
from flask import Flask, request, abort, jsonify, send_from_directory, Response, flash, render_template, session
import flask
import codecs

DOWNLOADS = "/app/my_resume/doc"

app = Flask(__name__)

"""
Move app setup tasks into create_app 
so we can reference from test harness
"""
def create_app(debug=True):

  app.debug = debug
  app.secret_key = os.urandom(12)

  if 'S3_KEY' in os.environ:
    debug = False
    username = os.environ['S3_KEY']
    password = os.environ['S3_SECRET']
  else:
    username = 'admin'
    password = 'admin'

  # set up your database
  #app.engine = create_engine(database_uri)

  # add your modules
  #app.register_module(frontend)
                      
  # other setup tasks

  return app

@app.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin Diaz Resume')

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

@app.errorhandler(404)
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
  app = create_app(debug=True)
  app.run(host="0.0.0.0")

"""
   _____                _    _ _         ____                                
  |  ___| __ __ _ _ __ | | _| (_)_ __   |  _ \ ___  ___ _   _ _ __ ___   ___ 
  | |_ | '__/ _` | '_ \| |/ / | | '_ \  | |_) / _ \/ __| | | | '_ ` _ \ / _ \
  |  _|| | | (_| | | | |   <| | | | | | |  _ <  __/\__ \ |_| | | | | | |  __/
  |_|  |_|  \__,_|_| |_|_|\_\_|_|_| |_| |_| \_\___||___/\__,_|_| |_| |_|\___|
                                                                             
"""