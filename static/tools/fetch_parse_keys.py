#!/usr/bin/env python3
# fetch_parse_keys.py

import os
import sys
import inspect
import argparse
import json
import tempfile
from zipfile import ZipFile
import requests
#import struct
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
#basedir = os.path.abspath(os.path.dirname(__file__))
sys.path.insert(0, parentdir)
from config import Config
from lib.diagnosis_keys import DiagnosisKeys
from lib.conversions import get_local_timestamp
from lib.conversions import *

parser = argparse.ArgumentParser()
parser.add_argument('-e', action='store', dest='environment',
                    help="omgeving")
args = parser.parse_args()
environment = args.environment

def write_json(path, json_data):
    with open(path, 'w') as file_out:
        json.dump(json_data, file_out)

def read_json(path):
    with open(path) as file_in:
        return json.load(file_in)

if environment:
    datastore = Config.DATA_STORE
    headers = Config.REQUEST_HEADERS
    #headers = {
    #    'Content-Type': 'application/json',
    #    'User-Agent': 'joosts-check/2.00',
    #}
    sig = ''

    t_dir = tempfile.mkdtemp(dir='/var/tmp')
    url = "https://" + environment + ".coronamelder-dist.nl"
    manifesturl = '%s/v1/manifest%s' % (url, sig)
    #print(datastore)
    print("INFO: retrieving manifest from '{}'.. ".format(manifesturl), end='')

    try:
        r = requests.get(manifesturl, headers=headers)
        r.raise_for_status()
    except requests.exceptions.HTTPError as err:
        print(err)
        sys.exit()

    if r.ok:
        zname = os.path.join(t_dir, 'manifest.zip')
        zfile = open(zname, 'wb')
        zfile.write(r.content)
        print("OK")
        zfile.close()

    if zname:
        with ZipFile(zname, 'r') as zipObj:
            zipObj.extractall(t_dir)

    json_obj_file = os.path.join(t_dir, 'content.bin')
    with open(json_obj_file) as json_file:
        json_obj = json.load(json_file)

    exposurekeysets = json_obj['exposureKeySets']
    no_keysets = len(exposurekeysets)
    json_obj['no_keysets'] = no_keysets
    retrieval_timestamp = get_local_timestamp()
    json_obj['retrievaltimestamp'] = retrieval_timestamp
    json_obj['manifest_pki_signature'] = "TODO"

    environment_json = json_obj
    #print(json.dumps(environment_json, indent=2))

    datastore_filename = "%s.json" % environment
    datastore_file = os.path.join(datastore, datastore_filename)
    print("INFO: writing to datastore '{}'.. ".format(datastore_filename), end='')
    write_json(datastore_file, environment_json)
    print("OK")

    counter = 0
    for exposurekeyset in exposurekeysets:

        counter += 1
        print("INFO: {}/{} retrieving exposure keyset '{}'.. ".format(counter, no_keysets, exposurekeyset), end='')
        #curl ${=CFLAGS} --output eks.zip "$URL/v1/exposurekeyset/$exposureKeySets$SIG"

        keyseturl = '%s/v1/exposurekeyset/%s%s' % (url, exposurekeyset, sig)
        try:
            r = requests.get(keyseturl, headers=headers)
            r.raise_for_status()
        except requests.exceptions.HTTPError as err:
            print(err)

        if r.ok:
            zname = os.path.join(t_dir, 'eks.zip')
            zfile = open(zname, 'wb')
            zfile.write(r.content)
            print("OK")
            zfile.close()

        dk = DiagnosisKeys(zname)
        key_json_obj = dict()

        start_timestamp = get_local_datetime(dk.get_upload_start_timestamp())
        end_timestamp = get_local_datetime(dk.get_upload_end_timestamp())

        key_json_obj["timeWindowStart"] = get_string_from_datetime(start_timestamp)
        key_json_obj["timeWindowEnd"] = get_string_from_datetime(end_timestamp)
        key_json_obj["region"] = dk.get_region()
        key_json_obj["batchNum"] = dk.get_batch_num()
        key_json_obj["batchCount"] = dk.get_batch_size()

        key_json_obj["signatureInfos"] = dict()
        for signature_info in dk.get_signature_infos():
            for line in str(signature_info).split("\n"):
                line = line.strip()
                if line:
                    key_json_obj["signatureInfos"][line.split(":")[0]] = line.split(":")[1].replace('"', "").strip()

        key_json_obj["diagnosisKeys"] = []
        i = 0
        for tek in dk.get_keys():
            i += 1
            start_timestamp = get_local_datetime(start_timestamp)
            end_timestamp = get_local_datetime(end_timestamp)
            key = dict()
            key["TemporaryExposureKey"] = tek.key_data.hex()
            key["transmissionRiskLevel"] = tek.transmission_risk_level
            key["validity"] = dict()
            key["validity"]["start"] = get_string_from_datetime(start_timestamp)
            key["validity"]["end"] = get_string_from_datetime(end_timestamp)
            key["validity"]["rollingStartIntervalNumber"] = tek.rolling_start_interval_number
            key["validity"]["rollingPeriod"] = tek.rolling_period
            key_json_obj["diagnosisKeys"].append(key)

        exposure_key_json = key_json_obj
        #print(json.dumps(exposure_key_json, indent=2))

        datastore_filename = "%s.json" % exposurekeyset
        datastore_file = os.path.join(datastore, datastore_filename)
        print("INFO: writing to datastore '{}'.. ".format(datastore_filename), end='')
        write_json(datastore_file, environment_json)
        print("OK")


else:
    print("ERR: please provide environment (eg. '-e test')")
