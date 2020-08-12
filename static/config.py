import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config():
    SECRET_KEY = 'you-will-never-guess'
    FREEZER_RELATIVE_URLS = False
    FREEZER_IGNORE_MIMETYPE_WARNINGS = True
    DATA_STORE = os.path.join(basedir, 'datastore')
    REQUEST_HEADERS = {
        'Content-Type': 'application/json',
        'User-Agent': 'joosts-check/2.00',
    }
