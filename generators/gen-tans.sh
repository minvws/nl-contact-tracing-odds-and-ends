#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
#
URL=${ODDS_ENDS_ENDPOINT_API:-https://test.coronamelder-api.nl/v1}

set -e
if [ $# -gt 1 ]; then
  # heh.. this never appears. Todo: add this behind -h
	echo "Syntax: $0"
  echo "\n"
  echo "By default, uses test API. If you want to test against a different (e.g. local dev) env, set ODDS_ENDS_ENDPOINT_API to for example http://localhost"
	exit 1
fi

for j in 1 2 3 4 5 6 7 8 9 10
do
 
echo '{"padding":"Yg=="}' |\
curl  -X POST \
	--silent  \
	--data @- \
	-H 'Content-Type: application/json' \
	$URL/register |\
	json_pp |\
	grep  labConfirmationId | sed -e 's/.*: //' -e 's/"//g' -e 's/,$//' 
done

