#!/bin/bash

python3 tools/fetch_parse_keys.py -e test
python3 tools/fetch_parse_keys.py -e productie
python3 tools/fetch_parse_keys.py -e acceptatie

exit 0
