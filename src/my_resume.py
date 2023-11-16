# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import os

from flask import Flask, render_template, request, redirect
from flask_weasyprint import HTML, render_pdf

app = Flask(__name__)


def create_app(debug):
    """Move app setup tasks into create_app so we can reference from test harness."""
    app.debug = debug
    app.secret_key = os.urandom(12)
    return app


@app.before_request
def beforeRequest():
    """https://stackoverflow.com/questions/15116312/redirect-http-to-https-on-flaskheroku

    Returns:
        _type_: _description_
    """
    if not request.url.startswith("https"):
        return redirect(request.url.replace("http", "https", 1))


@app.route("/")
def render_static():
    """Render the HTML page."""
    return render_template("index.html", title="Franklin Diaz Resume")


@app.route("/pdf")
def build_pdf():
    """Generate a PDF file from HTML."""
    # css = ["src/static/css/new-style.css"]
    html = render_template("index.html")
    return render_pdf(HTML(string=html), download_filename="franklin_diaz_resume.pdf")


@app.route("/bio")
def render_bio():
    """Render the HTML biography."""
    return render_template("bio.html", title="Franklin Diaz Biography")


@app.route("/biopdf")
def build_bio():
    """Generate a PDF Biography file from HTML."""
    # css = ["src/static/css/new-style.css"]
    html = render_template("bio.html")
    return render_pdf(
        HTML(string=html), download_filename="franklin_diaz_biography.pdf"
    )


@app.route("/palobio")
def render_palo_bio():
    """Render the HTML biography."""
    return render_template("palo_bio.html", title="Franklin Diaz Palo Alto Biography")


@app.route("/palobiopdf")
def build_palo_bio():
    """Generate a PDF Biography file from HTML."""
    # css = ["src/static/css/new-style.css"]
    html = render_template("palo_bio.html")
    return render_pdf(
        HTML(string=html), download_filename="franklin_diaz_palo_alto_biography.pdf"
    )


@app.errorhandler(404)
def page_not_found(my_err):
    """Return a custom 404 error page."""
    if request.method == "POST":
        if request.form["submit_button"] == "Go Back to Resume":
            return render_template("index.html", title="Franklin Diaz Resume")
    elif request.method == "GET":
         return render_template('404.html', title = '404'), 404
    else:
        pass
    return my_err
   

if __name__ == "__main__":
    create_app(debug=False)
    # create app(debug=True)
    app.run(host="127.0.0.1")
    # app.run(host="0.0.0.0", port="5000")
