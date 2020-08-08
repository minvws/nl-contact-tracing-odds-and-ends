#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
#
set -e
if [ $# != 2 ]; then
	echo "Syntax: $0 <payload> <cid>"
	exit 1
fi

PAYLOAD=$1
CID=$2 

KEY=`echo "$CID" | base64 -d | xxd -p -c 256`

/bin/echo -n "$PAYLOAD" | openssl sha256 -mac HMAC -macopt hexkey:$KEY -binary |\
	 base64 | sed -e 's/"//g' -e 's/+/%2B/g' -e 's/=/%3D/g' -e 's/\//%2F/g'
