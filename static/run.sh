#!/bin/bash

testscripts_path="../test-tools"

testscripts=" \
patch-static-html-testscript-environment.sh \
patch-static-html-testscript-register-post-teks.sh
"

outdir=$(mktemp -d -t run-XXXXXXX)
static_out="static_out"
RET=1

echo "INFO: generating static html"

echo "INFO: phase 1 = run test script(s)"

for testscript in ${testscripts}; do
    echo "      script: ${testscript}"
    ${testscripts_path}/${testscript} > ${outdir}/${testscript}.out
    status=$?
    if test $status -eq 0; then
        echo "      INFO: script: ${testscript} ok"
        echo "      INFO: output in ${outdir}/${testscript}.out"
    else
        echo "      ERR : script: ${testscript} not ok"
    fi

done

echo "INFO: phase 2 = collect output"

for testscript in ${testscripts}; do
    if test -f ${outdir}/${testscript}.out; then
        cp ${outdir}/${testscript}.out templates/${testscript}.html
    fi
done

echo "INFO: phase 3 = generate static html"
python serve.py &
PYTHON_PID=$!

sleep 5

if test -f $static_out/index.html; then
    rm -f $static_out/index.html
fi
curl --silent http://127.0.0.1:5000/ -o $static_out/index.html

status=$?
if test $status -eq 0; then
    if test -f $static_out/index.html; then
        echo "INFO: static html ok"
    fi
else
    echo "ERR : kill python process ($PYTHON_PID) not ok"
fi

kill $PYTHON_PID
status=$?
if test $status -eq 0; then
    echo "INFO: kill python process ($PYTHON_PID) ok"
    RET=0
else
    echo "ERR : kill python process ($PYTHON_PID) not ok"
fi

exit $RET
