#!/bin/bash

scripts_path="../test-tools"

scripts=" \
patch-static-html-testscript-environment.sh \
patch-static-html-testscript-register-post-teks.sh
"

outdir=$(mktemp -d -t run-XXXXXXX)
static_out="build"
RET=1

echo "INFO: generating static html"

echo "INFO: phase 1 = run test script(s)"

for script in ${scripts}; do
    ${scripts_path}/${script} > ${outdir}/${script}.out
    status=$?
    if test $status -eq 0; then
        echo "      INFO: script: ${script} ok"
        #echo "      INFO: output in ${outdir}/${testscript}.out"
    else
        echo "      ERR : script: ${script} not ok"
    fi

done

echo "INFO: phase 2 = collect output"

for script in ${scripts}; do
    if test -f ${outdir}/${script}.out; then
        cp ${outdir}/${script}.out templates/${script}.html
    fi
done

echo "INFO: phase 3 = generate static html"
python serve.py build
status=$?
if test $status -eq 0; then
    if test -f $static_out/index.html; then
        echo "INFO: python build ok"
    fi
    RET=0
else
    echo "ERR : python build not ok"
fi

exit $RET
