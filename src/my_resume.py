import os
import logging
import logging.config   

from flask import Flask, render_template, request
from flask_weasyprint import HTML, render_pdf

app = Flask(__name__)

logging.config.fileConfig(
    "logging.conf",
    defaults={"logfilename": "resume.log"},
    disable_existing_loggers=False,
)
logger = logging.getLogger("__name__")


def create_app(debug):
    """Move app setup tasks into create_app so we can reference from test harness."""
    app.debug = debug
    app.secret_key = os.urandom(12)
    return app


@app.route("/")
def render_static():
    """Render the HTML page."""
    return render_template("index.html", title="Franklin Diaz Resume")


@app.route("/pdf")
def build_pdf():
    """Generate a PDF file from a string of HTML."""
    html = render_template("index.html")
    return render_pdf(HTML(string=html), download_filename="franklin_diaz_resume.pdf")


@app.errorhandler(404)
def page_not_found(my_err):
    """Return a custom 404 error page."""
    if request.method == "POST":
        if request.form["submit_button"] == "Go Back to Resume":
            return render_template("index.html", title="Franklin Diaz Resume")
    elif request.method == "GET":
        return render_template("404.html"), 404
    else:
        pass
    return my_err


if __name__ == "__main__":
    create_app(debug=True)
    app.run(host="127.0.0.1")


"""my_resume application

    __copyright__ = © 2021 by Franklin Diaz
    __license__   = MIT
"""
