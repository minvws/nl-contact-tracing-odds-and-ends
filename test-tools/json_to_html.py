import sys

import json
from json2html import *

jsonfile = sys.argv[1]
with open(jsonfile) as f:
    d = json.load(f)
    html = json2html.convert(json=d, table_attributes="id=\"verify-table\" class=\"table table-bordered table-hover table-compact\"")
    print(html)
