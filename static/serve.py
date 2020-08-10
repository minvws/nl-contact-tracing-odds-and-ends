# serve.py

import sys
from datetime import datetime

from flask import Flask
from flask import render_template
from flask_frozen import Freezer
from flask_flatpages import (
    FlatPages, pygmented_markdown, pygments_style_defs)

# creates a Flask application, named app
app = Flask(__name__)
freezer = Freezer(app)


# default route
@app.route("/")
def index():
    return render_template('index.html')

# run the application
if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'build':
        freezer.freeze()
    else:
    	app.run(debug=True)
