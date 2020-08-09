#!/bin/sh 

for i in test acceptatie productie; do

    echo "<p>"
    echo "<h2>Environment $i</h2>"
    for j in api dist portal; do
        echo -n "  ${i}.coronamelder-$j.nl"
        if curl --fail --silent https://${i}.coronamelder-$j.nl/ >/dev/null 2>&1; then
		    echo " <b>OK</b>"
	    else
		    echo " <b>Not yet available/error</b>"
	    fi
        echo "<br>"
    done
    echo "</p>"
done

datum=`date`
echo "<p><i>Bijgewerkt: ${datum}</i>"
exit 0
