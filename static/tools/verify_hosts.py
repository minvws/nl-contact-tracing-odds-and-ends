#!/usr/bin/env python3
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('-e', action='store', dest='environment',
                    help="omgeving")

args = parser.parse_args()

environment = args.environment


def fetch_manifest():
    json_obj = dict()
    print(environment)
    return json.dumps(json_obj, indent=4)

if __name__ == '__main__':
    ret = fetch_manifest()
