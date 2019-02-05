from flask import Flask, render_template

my_resume = Flask(__name__)

@my_resume.route('/<string:page_name>/')
def render_static(page_name):
  return render_template('%s.html' % page_name)</string:page_name>

if __name__ == '__main__':
  my_resume.run()
