from flask import Flask, render_template

my_resume = Flask(__name__)

@my_resume.route('/')
def render_static():
  return render_template('index.html')

if __name__ == '__main__':
  my_resume.run(debug=True)
