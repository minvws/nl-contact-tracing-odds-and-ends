#!/usr/bin/env zsh
TMPDIR=${TMPDIR:-/tmp}
DIR=$0:A
# set -e

CFLAGS="--silent --fail -H User-Agent:dirkx-check/1.00"

if [ "x$1" = "x--kpn" ]; then
	echo "** VIA KPN ***"
	CFLAGS+=" --resolve test.coronamelder-dist.nl:443:195.121.65.176"
	shift
fi
ENVIRONMENT=test
mydir=${0:a:h}
if [ $# = 1 ]; then
	if ! test -f "$mydir/gaen-pubkeys/$1.txt"; then
		echo "Syntax: $0 <environment, (default: $ENVIRONMENT)"
		exit 1
	fi
	ENVIRONMENT=$1
fi
GAENKEY="gaen-pubkeys/$ENVIRONMENT.txt"

URL=https://$ENVIRONMENT.coronamelder-dist.nl
SIG=''

export TMPDIR=${TMPDIR:-/tmp}

(
mkdir -p $TMPDIR/get.$$
cp $mydir/$GAENKEY $TMPDIR/get.$$/pub-key.pem
cd $TMPDIR/get.$$

{

# get manifest
if ! curl ${=CFLAGS} \
	--output manifest.zip \
	-H 'accept: application/zip' \
	\
	"$URL/v1/manifest$SIG"
then
	echo Fetch of manifest failed.
	exit 1
fi

if [ ! -s manifest.zip ]; then
	echo Zero length
	exit 1
fi

if ! unzip -qq manifest.zip; then
	ls -l manifest.zip
	cat  manifest.zip | strings
	exit 1
fi
test -f content.sig
test -f content.bin

echo Manifest:
# get root cert to verify against.
curl --silent http://cert.pkioverheid.nl/RootCA-G3.cer | openssl x509 -inform DER -out ca-pki-overheid.pem

# Reconstruct the protobuff definition; source: https://github.com/google/exposure-notifications-server/blob/1208580e92e3a9f23d85eb570fbdff8d1f6e7a00/internal/pb/export/export.proto
#
echo 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 | base64 -d | gunzip > export.proto

# check that root is the version build into the apps
# ... todo ...

# validate signature
checksig() {
R=OK
openssl cms -verify -binary -CAfile ca-pki-overheid.pem -inform DER -in $1 -content $2 -purpose any -signer sig.pem -certsout ch.pem 2>/dev/null >/dev/null || R=FAIL
echo "     Manifest PKI signature $R-CMS "
cat ch.pem | gawk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "cert." c ".pem"}'
for i in cert.*.pem
do
	C=`exec openssl x509 -in $i -noout -subject -nameopt RFC2253 |\
		sed 	-e "s!subject=!!" \
			-e s'!.serialNumber=[A-Za-z0-9]*!!g' \
			-e s'!.organizationIdentifier=[A-Za-z0-9]*!!g' \
  		 	-e 's!subject=!!'`
	echo "     $C"
done
/bin/echo -n "     Date: "
cmsdateextract content.sig
rm ch.pem cert.*.pem
}

checksig  content.sig content.bin  || exit 1

for i in riskCalculationParameters appConfig
do
  (
	i=`echo $i | tr A-Z a-z`
        mkdir $i
	L=`cat content.bin | json_pp | grep -i $i | sed -e 's/.*: "//' -e 's/".*//'`
        if [ x$L = "x" ]; then
		echo Could not find $i in manifest. Manifest is:
		cat content.bin | json_pp 
		exit 1
	fi

	curl ${=CFLAGS} --output $i/$i.zip "$URL/v1/$i/$L"

	if [ ! -s $i/$i.zip ]; then
		ls -l $i
		echo Zero lenght $i.
		exit 1
	fi
	rm -f $i/content.sig $i/content.bin 
	if ! unzip -qq $i/$i.zip -d $i; then
		ls -l $i/$i.zip
		echo Contents ZIP file:
		cat  $i/$i.zip | strings
		exit 1
	fi
        echo " * $i:"
        checksig  $i/content.sig $i/content.bin  || exit 1
   )
done || exit 1

L=`cat content.bin | json_pp | grep -v : | grep -v '{' | grep '"' | sed -e 's/"//g' -e 's/,$//' | wc -l`
if [ $L -eq 0 ]; then
	# cat content.bin | json_pp 
	echo " * No keys"
	exit
fi
openssl cms -verify -binary -CAfile ca-pki-overheid.pem -inform DER -in content.sig -content content.bin -purpose any > /dev/null 2>/dev/null
echo " * fetching each keyset:"
echo 0 > keycount.txt
cat content.bin | json_pp | grep -v : | grep -v '{' | grep '"' | sed -e 's/"//g' -e 's/,$//' | while read exposureKeySets
do
	mkdir -p $exposureKeySets
	(	
		echo " - $exposureKeySets"
		cd $exposureKeySets
		if ! curl ${=CFLAGS} --output eks.zip "$URL/v1/exposurekeyset/$exposureKeySets$SIG"; then
			echo "    url fetch failed."
			exit
		fi

		if ! unzip -qq -o eks.zip; then
			echo "    unzip failed."
			exit
		fi

		# check payload
	        if cat export.bin| tail +17c | protoc --decode TemporaryExposureKeyExport -I.. export.proto | grep -q verification_key_id; then
	        	if C=`cat export.bin| tail +17c | protoc --decode TemporaryExposureKeyExport -I.. export.proto | grep key_data | wc -l | sed -e 's/ //g'`; then
				VERSION=`cat export.sig| protoc --decode TEKSignatureList -I.. export.proto | grep 'verification_key_version' | awk '{ print $2 }' | sed -e 's/"//g' `
				ID=`cat export.sig| protoc --decode TEKSignatureList -I.. export.proto | grep 'verification_key_id' | awk '{ print $2 }' | sed -e 's/"//g' `
                                if [ "$C" = "0" ]; then
                                        echo "     protobuf export.bin WARNING - $C key(s) $VERSION/$ID"
                                else
                                        echo "     protobuf export.bin OK - $C key(s) $VERSION/$ID"
                                fi
				echo $C >> ../keycount.txt
			else
				echo "     protobuf export.bin FAIL"
			fi
		else
			echo " *** protobuf export.bin FAIL"
		fi

#cat export.bin| tail +17c | protoc --decode TemporaryExposureKeyExport -I.. export.proto | grep key_data | sed -e  's/.*: "//' -e 's/"$//' 

		# validate unmanaged google/apple signature.
		R=`cat export.sig| protoc --decode TEKSignatureList -I.. export.proto |\
	 grep signature: | \
	sed -e  's/^ *signature: "//' -e 's/"$//' -e 's/ /\\ /g' `
	print -n $R >  signature.raw

		if ! openssl asn1parse -inform DER -in signature.raw 2>/dev/null >/dev/null; then
			echo " *** FAIL on GAEN signatature.raw"
		else
			if openssl dgst -sha256 -verify ../pub-key.pem -signature signature.raw export.bin >/dev/null; then
				echo "     unmanaged GAEN signature OK"
			else
				echo "     unmanaged GAEN signature FAIL"
			fi
		fi


		# validate signature on content.bin TEKs
		# if openssl cms -verify -CAfile ../ca-pki-overheid.pem -inform DER -in content.sig -content export.bin -purpose any  > /dev/null 2> /dev/null; then
		if openssl cms -binary -verify -CAfile ../ca-pki-overheid.pem -inform DER -in content.sig -content export.bin -purpose any > /dev/null 2>/dev/null; then
			echo "     outer sig OK"
		else
			echo " *** FAIL on Outer PKI signature"
		fi
	)
done
echo Total keys: `awk '{ sum += $1 } END { print sum }' keycount.txt`
}
) || E=$? && echo OK
rm -rf $TMPDIR/get.$$
exit $E
