#!/bin/sh 
true > /tmp/this
for ENVIRONMENT in test acceptatie productie
do
export ENVIRONMENT
echo "<h1>Test $ENVIRONMENT</h1><hr>Fetch manifest, settings and riskparams; then fetch all keys (via KPN)"

echo "<pre>"
S=FAIL
if /usr/local/corona/nl-contact-tracing-odds-and-ends-private/test-tools/check-manifest-eks-and-verify.zsh $ENVIRONMENT 2>&1
then
	S="ok"
fi
echo "$ENVIRONMENT::dist=$S" >> /tmp/this

echo "</pre>"

echo "<hr>Register and post of TEKs on $ENVIRONMENT"

echo "<pre>"
S="FAIL"
if /usr/local/corona/nl-contact-tracing-odds-and-ends-private/test-tools/check-posting.sh 2>&1; then
	S="ok"
else
	echo FAIL
fi
echo "$ENVIRONMENT::api=$S" >> /tmp/this

echo "</pre>"
done

D=`cat /tmp/this`
DD=`date`
echo $DD $D >> /tmp/log

if [ -n "$TOKEN" ]; then
if ! diff -q /tmp/last /tmp/this; then
	curl --silent -X POST -H 'Content-type: application/json' \
		--data "{\"text\":\"Situation now: $D -- see http://bastion.coronamelder-dist.nl:2020/corona.html\"}" \
		https://hooks.slack.com/services/$TOKEN > /dev/null 2>&1
fi
fi
cp /tmp/this /tmp/last

echo "<h1>Servers</h1><hr>"
for i in test acceptatie productie; do
  echo "<h2>Environment $i</h2>"
  for j in api dist portal; do
    ii="$i."
    if [ $i = "productie" -a $j != "dist" ]; then
	ii=""
    fi

    echo "<h3>Service $i::$j</h3>"
    echo "Checking ${ii}coronamelder-$j.nl<p>"
    echo "<pre>"
    if curl --fail --silent https://${ii}coronamelder-$j.nl/ >/dev/null 2>&1; then
	    if [ "x$j" = "xportal" ]; then
		echo OK
	else
		curl --silent https://$i.coronamelder-$j.nl/
	fi
	else
		echo Not yet available/error
	fi
    echo "</pre>"
  done
done

echo "<i>Last ran"
date
exit 
