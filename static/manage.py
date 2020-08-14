#!/usr/bin/env python3
# manage.py

import os
#import sys
from pathlib import Path
import json
from flask import Flask
from flask import render_template
from flask_frozen import Freezer
from flask_script import Manager
from config import Config

app = Flask(__name__)
app.config.from_object(Config)
freezer = Freezer(app)
manager = Manager(app)

datastore = Config.DATA_STORE
app_data = {}
app_data['title'] = Config.APP_TITLE
app_data['description'] = Config.APP_DESCRIPTION

def read_json(path):
    with open(path) as file_in:
        return json.load(file_in)

# default route
@app.route("/index.html")
def index():
    return render_template('index.html', app_data=app_data)

@app.route("/verify/<string:omgeving>/index.html")
def verify_index(omgeving):
    datastore_filename = "%s.json" % omgeving
    datastore_file = os.path.join(datastore, datastore_filename)
    data = read_json(datastore_file)
    return render_template('verify.html', omgeving=omgeving, data=data, app_data=app_data)

@app.route("/keyset/<string:keyset>/tek/<string:tek>/index.html")
def verify_tek(keyset, tek):
    datastore_filename = "%s.json" % keyset
    datastore_file = os.path.join(datastore, datastore_filename)
    data = read_json(datastore_file)
    return render_template('verify_tek.html', data=data, keyset=keyset, tek=tek, app_data=app_data)

@app.route("/keyset/<string:keyset>/index.html")
def verify_keyset(keyset):
    datastore_filename = "%s.json" % keyset
    datastore_file = os.path.join(datastore, datastore_filename)
    data = read_json(datastore_file)
    return render_template('verify_keyset.html', data=data, keyset=keyset, app_data=app_data)

#URL generator
@freezer.register_generator
def verify_index():
    omgevingen = ['test', 'acceptatie', 'productie']
    for omgeving in omgevingen:
        yield {'omgeving': omgeving}

#URL generator
@freezer.register_generator
def verify_keyset():
    keysets = []
    for _, _, filenames in os.walk(datastore):
        for filename in filenames:
            if '.json' in filename:
                test_list = ['test.json', 'acceptatie.json', 'productie.json']
                if filename not in test_list:
                    f = Path(filename).stem
                    keysets.append(f)
    for keyset in keysets:
        yield {'keyset': keyset}

#URL generator
@freezer.register_generator
def verify_tek():
    keysets = {}
    for _, _, filenames in os.walk(datastore):
        for filename in filenames:
            if '.json' in filename:
                test_list = ['test.json', 'acceptatie.json', 'productie.json']
                if filename not in test_list:
                    f = Path(filename).stem
                    teklist = []
                    r = read_json(os.path.join(datastore, filename))
                    for i in r['diagnosisKeys']:
                        for k, v in i.items():
                            if k == 'TemporaryExposureKey':
                                teklist.append(v)
                    keysets[f] = teklist

    for k, v in keysets.items():
        for tek in v:
            yield {'keyset': k, 'tek': tek}


@manager.command
def freeze():
    freezer.freeze()

# run the application
if __name__ == '__main__':
    manager.run()
