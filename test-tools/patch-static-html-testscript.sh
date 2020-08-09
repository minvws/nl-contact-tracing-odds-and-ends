#!/bin/sh 

for i in test acceptatie productie; do

    echo "<h2>Environment $i</h2>"
    for j in api dist portal; do
        echo "<h3>Service $i::$j</h3>"
        echo -n "  ${i}coronamelder-$j.nl"
        if curl --fail --silent https://${i}.coronamelder-$j.nl/ >/dev/null 2>&1; then
		    echo " <b>OK</b>"
	    else
		    echo " <b>Not yet available/error</b>"
	    fi
    done
done

echo -n "<i>Last ran</i>"
date
exit 0
