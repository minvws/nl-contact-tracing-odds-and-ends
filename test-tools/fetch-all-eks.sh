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

OUTDIR=`dirname $PWD/$0`
if [ $# = 1 ]; then
	OUTDIR=$PWD/$ENV
else
	OUTDIR=`pwd`/$2
fi

mkdir -p $OUTDIR
echo Storing output in $OUTDIR

mkdir -p $TMPDIR/get.$$
cd $TMPDIR/get.$$

{
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

echo fetching each keyset:
cat content.bin | json_pp | grep -v : | grep -v '{' | grep '"' | sed -e 's/"//g' -e 's/,$//' | while read exposureKeySets
do
	/bin/echo -n " - <$exposureKeySets>: "
	if test -f "$OUTDIR/eks-$exposureKeySets.zip"; then
		echo Skipping - already present.
	else
		curl --silent --output eks.zip "$URL/v1/exposurekeyset/$exposureKeySets$SIG"
		mv eks.zip "$OUTDIR/eks-$exposureKeySets.zip"
		unzip eks.zip -d tmp
		mv tmp/content.bin  "$OUTDIR/eks-$exposureKeySets.content-protoc"
		echo ok
	fi
done
}
rm -rf $TMPDIR/get.$$
