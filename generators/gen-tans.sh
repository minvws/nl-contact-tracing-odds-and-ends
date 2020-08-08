#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
#
URL=https://test.coronamelder-api.nl

set -e
if [ $# -gt 1 ]; then
	echo "Syntax: $0 [payload]"
	exit 1
fi

for j in 1 2 3 4 5 6 7 8 9 10
do

PAYLOAD='{"keys":[{"keyData":"EaMR2wpMuSMMw3wSy32HEQ==","rollingStartNumber":RT,"rollingPeriod":72}],"bucketId":"BUCK","padding":"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="}' 
if [ $# -eq 1 ]; then
	PAYLOAD=`cat "$1"`
fi
 
echo '{"padding":"Yg=="}' |\
curl  -X POST \
	--silent  \
	--data @- \
	-H 'Content-Type: application/json' \
	$URL/mss-acc/v1/register |\
	json_pp |\
	grep  labConfirmationId | sed -e 's/.*: //' -e 's/"//g' -e 's/,$//' 
done

