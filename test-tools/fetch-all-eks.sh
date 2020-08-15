#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

TMPDIR=${TMPDIR:-/tmp}


if [ $# -gt 2 -o $# -lt 1 ]; then
	echo "$0 <environment> [outdir]"
	exit 1
fi
ENV=$1

URL=https://$ENV.coronamelder-dist.nl

SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPT")

OUTDIR=`dirname $PWD/$0`
if [ $# = 1 ]; then
	OUTDIR=$PWD/$ENV
else
	OUTDIR=$2
fi

mkdir -p $OUTDIR
echo Storing output in $OUTDIR

mkdir -p $TMPDIR/get.$$
cd $TMPDIR/get.$$

#{
echo Manifest:

# get manifest
curl \
	--silent \
	--output manifest.zip \
	\
	 -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, li,image/svg+xml,image/*;q=0.8,video/*;q=0.8,*/*;q=0.5' \
	-H 'Accept-Language: en-gb' \
	-H 'Connection: keep-alive' \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H 'accept: application/zip' \
	\
	"$URL/v1/manifest$SIG"
echo "     fetched ok"

rm -f content.bin content.sig
unzip -q manifest.zip
test -f content.sig
test -f content.bin
echo "     unzipped ok"

mkdir -p "${OUTDIR}/manifest"
rm -f "${OUTDIR}/manifest/*"
cp manifest.zip content.sig content.bin "${OUTDIR}/manifest"
cat content.bin | json_pp > "${OUTDIR}/manifest/content.txt"

# get root cert to verify against.
curl --silent http://cert.pkioverheid.nl/RootCA-G3.cer | openssl x509 -inform DER -out ca-pki-overheid.pem

cat <<EOM > pub-key.pem
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEBlg7P7K1cP6vrQ1rIfKnCjsPKGb3
IwLs55lIMIk7TydGzKUDn7+yw6UjFZIJxlD/hmjofZ1mmIykOLcir1meKg==
-----END PUBLIC KEY-----
EOM
# validate signature
openssl cms -verify -CAfile ca-pki-overheid.pem -inform DER -in content.sig -content content.bin -purpose any > /dev/null 2>/dev/null
echo "     Manifest PKI signature OK."
/usr//local/bin/cmsdateextract  content.sig 
/bin/echo -n "    Date (signed): "
cp content.bin content.list

for w in appconfig riskcalculationparameters
do 
	hid=`cat content.list | json_pp | grep -i $w | sed -e 's/.*: \"//g' -e 's/".*$//'`
	rm -f content.bin content.sig
	mkdir -p "${OUTDIR}/$w"
	rm -f "${OUTDIR}/$w/*"
	curl --silent --output "$w.zip" "$URL/v1/$w/$hid"
	if unzip $w.zip; then
		cp $w.zip content.sig content.bin "${OUTDIR}/$w"
		(
                        /bin/echo -n "Generated (signed): "
			/usr//local/bin/cmsdateextract  content.sig 
			echo
			cat content.bin | (json_pp|| echo json decode fail)
		) > "${OUTDIR}/$w/content.txt"
	fi
done


echo fetching each keyset:
echo > $OUTDIR/keys.txt
cat content.list | json_pp | grep -v : | grep -v '{' | grep '"' | sed -e 's/"//g' -e 's/,$//' | while read exposureKeySets
do
	/bin/echo -n " - [$exposureKeySets]: "
	if test -d "$OUTDIR/eks-$exposureKeySets"; then
		echo Skipping - already present.
	else
		curl --silent --output eks.zip "$URL/v1/exposurekeyset/$exposureKeySets$SIG"
		unzip -q eks.zip -d tmp
		mkdir -p "$OUTDIR/eks-$exposureKeySets"
		mv eks.zip "$OUTDIR/eks-$exposureKeySets/eks.zip"
		cp tmp/*  "$OUTDIR/eks-$exposureKeySets"
		cat tmp/export.bin | tail +17c > "$OUTDIR/eks-$exposureKeySets/export.protoc"
		(
                        /bin/echo -n "Generated (signed): "
			/usr//local/bin/cmsdateextract  content.sig 
			echo
			cat tmp/export.bin | $SCRIPTDIR/dump_exportbin 
		) > "$OUTDIR/eks-$exposureKeySets/export.txt"
		rm -rf tmp
		echo ok
	fi
	# gather the readable key dumps in one keys.txt file for easy querying on a key in the entire set
	KEYCNT=`grep -c key_data $OUTDIR/eks-$exposureKeySets/export.txt`
	echo ====== $(date -r $OUTDIR/eks-$exposureKeySets/export.txt) $exposureKeySets/export.txt - $KEYCNT keys ===== >> $OUTDIR/keys.txt
	cat $OUTDIR/eks-$exposureKeySets/export.txt >> $OUTDIR/keys.txt
	echo >> $OUTDIR/keys.txt
done
# }
rm -rf $TMPDIR/get.$$
