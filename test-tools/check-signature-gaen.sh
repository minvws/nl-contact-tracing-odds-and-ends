#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}

if [ $# != 2 ]; then
	echo "$0 <base64-payload> <base64-confirmationKey>"
	exit 1
fi

PAYLOAD="$1"
KEY="$2"

if [ -f "$PAYLOAD" ]; then
	PAYLOAD=`cat "$PAYLOAD"`
fi

# test case 4 fro RFC 4231
#
TEST_VECTOR_KEY=0102030405060708090a0b0c0d0e0f10111213141516171819
TEST_VECTOR_DATA=cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd
TEST_VECTOR_RESULT=82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b

set `echo $TEST_VECTOR_DATA | xxd -r -p | openssl sha256 -mac hmac -macopt hexkey:$TEST_VECTOR_KEY`
if [ "x$2" != "x$TEST_VECTOR_RESULT" ]; then
	echo RFC4232 case 4 check failed. Aborted.
	exit 1
fi

KEY=`echo "$KEY" | base64 -d | xxd -p -c 256`
echo $PAYLOAD | base64 -d | openssl sha256 -mac HMAC -macopt hexkey:$KEY -binary | base64

