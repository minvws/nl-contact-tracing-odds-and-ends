import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config():
    DEBUG = True
    SECRET_KEY = 'you-will-never-guess'
    FREEZER_RELATIVE_URLS = True
    FREEZER_IGNORE_MIMETYPE_WARNINGS = True
    DATA_STORE = os.path.join(basedir, 'datastore')
    REQUEST_HEADERS = {
        'Content-Type': 'application/json',
        'User-Agent': 'joosts-check/2.00',
    }
    APP_TITLE = 'APP_TITLE'
    APP_DESCRIPTION = "app description lorum ipsum"
