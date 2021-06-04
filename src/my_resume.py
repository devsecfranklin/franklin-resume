"""
    my_resume application

    :copyright: (c) 2021 by Franklin Diaz
    :license: MIT
"""
# -*- coding: utf-8 -*-

import os

from flask import Flask, jsonify, render_template, request, send_from_directory
from flask_weasyprint import HTML, render_pdf

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


@app.route("/")
def render_static():
    """needs docstring"""
    return render_template("index.html", title="Franklin Diaz Resume")


@app.route("/pdf")
def build_pdf():
    """Generate a PDF file from a string of HTML."""
    html = render_template("index.html")
    return render_pdf(HTML(string=html), download_filename="franklin_diaz_resume.pdf")


@app.errorhandler(404)
def page_not_found(my_err):
    """needs a docstring"""
    if request.method == "POST":
        if request.form["submit_button"] == "Go Back to Resume":
            return render_template("index.html", title="Franklin Diaz Resume")
    elif request.method == "GET":
        # note that we set the 404 status explicitly
        return render_template("404.html"), 404
    else:
        pass
    return my_err


if __name__ == "__main__":
    create_app(debug=True)
    app.run(host="0.0.0.0")
