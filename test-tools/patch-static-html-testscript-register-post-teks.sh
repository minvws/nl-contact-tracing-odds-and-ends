#!/bin/sh 

for i in test acceptatie productie; do

    echo "<p>"
    echo "<h2>Register and post of TEKS on $i</h2>"
    echo "</p>"
done

datum=`date`
echo "<p><i>Bijgewerkt: ${datum}</i>"
exit 0
