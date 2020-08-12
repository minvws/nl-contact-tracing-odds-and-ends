#!/usr/bin/env python3
# manage.py

#import os
#import sys
#from pathlib import Path
#from datetime import datetime
from flask import Flask
from flask import render_template
from flask_frozen import Freezer
from flask_script import Manager
#from tools import verify_keysets
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
freezer = Freezer(app)
manager = Manager(app)


# default route
@app.route("/")
def index():
    return render_template('index.html')

@app.route("/verify/")
def verify_index():
    return render_template('verify.html')

@app.route("/verify/<string:exposure_keyset>/")
def verify_keyset_detail(exposure_keyset):
    keyset_detail_include = "keysets/%s.html" % exposure_keyset
    return render_template('verify_keyset_detail.html',
                           exposure_keyset=exposure_keyset,
                           keyset_detail_include=keyset_detail_include,
                           )

#URL generator
#@freezer.register_generator
#def verify_keyset_detail():
#    exposure_keysets = []
#    for d, dd, filenames in os.walk('templates/keysets'):
#        for filename in filenames:
#            if '.html' in filename:
#                f = Path(filename).stem
#                exposure_keysets.append(f)
#    for k in exposure_keysets:
#        yield {'exposure_keyset': k}

@manager.command
def freeze():
    freezer.freeze()

# run the application
if __name__ == '__main__':
    manager.run()
