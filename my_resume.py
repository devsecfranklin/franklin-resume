import subprocess
from flask import Flask, request, abort, jsonify, send_from_directory, Response, render_template
import codecs

DOWNLOADS = "/app/doc"

my_resume = Flask(__name__)

@my_resume.route('/')
def render_static():
  return render_template('index.html', title = 'Franklin D. Resume')

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
  # note that we set the 404 status explicitly
  return render_template('404.html'), 404

if __name__ == '__main__':
  bashCommand = "make html"
  process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
  output, error = process.communicate()
  my_resume.run(debug=True)
