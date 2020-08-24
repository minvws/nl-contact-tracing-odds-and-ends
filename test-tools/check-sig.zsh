#!/usr/bin/env zsh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

if [ $# -lt 2 ]; then
	echo "$0 <export.bin> <export.sig> [ecdsa-pubkey.pem]"
	exit 1
fi

mkdir -p $TMPDIR/get.$$
cp $1 $TMPDIR/get.$$
cp $2 $TMPDIR/get.$$

if [ $# = 3 ]; then
	cp "$3" $TMPDIR/get.$$/pub-key.pem
else
	cat <<EOM > $TMPDIR/get.$$/pub-key.pem
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEBlg7P7K1cP6vrQ1rIfKnCjsPKGb3
IwLs55lIMIk7TydGzKUDn7+yw6UjFZIJxlD/hmjofZ1mmIykOLcir1meKg==
-----END PUBLIC KEY-----
EOM
fi

cd $TMPDIR/get.$$

{

# Reconstruct the protobuff definition; source: https://github.com/google/exposure-notifications-server/blob/1208580e92e3a9f23d85eb570fbdff8d1f6e7a00/internal/pb/export/export.proto
#
echo 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 | base64 -d | gunzip > export.proto

if cat export.bin| tail +17c | protoc --decode TemporaryExposureKeyExport export.proto | grep -q rolling_start_interval_number; then
	        	C=`cat export.bin| tail +17c | protoc --decode TemporaryExposureKeyExport export.proto | grep key_data | wc -l`
			echo "     protobuf export.bin looks ok - $C keys"
else
	echo " *** protobuf export.bin FAIL"
fi

	R=`cat export.sig| \
	protoc --decode TEKSignatureList export.proto |\
	grep signature: |\
	sed -e  's/^ *signature: "//' \
             -e 's/"$//'  \
             -e 's/ /\\ /g' \
`
	print -n $R  > signature.raw

if ! openssl asn1parse -inform DER -in signature.raw 2>/dev/null >/dev/null; then
			echo " *** FAIL on GAEN signatature.raw"
else
			openssl dgst -sha256 -verify pub-key.pem -signature signature.raw export.bin >/dev/null
			echo "     unmanged GAEN signature OK"
fi
}
rm -rf $TMPDIR/get.$$
