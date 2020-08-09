#!/bin/sh 
for ENVIRONMENT in test acceptatie productie
do
    export ENVIRONMENT

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
done

echo -n "<i>Last ran</i>"
date
exit 0
