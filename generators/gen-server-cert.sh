#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
#
# Create a 'staat der nederlanden' root certificate that looks like
# the real thing. 
#
set -e

OPENSSL=${OPENSSL:-openssl}

#
if ! test -f ca.key; then
	echo Run gen-pki-overheid-fake.sh first.
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "Syntax: $0 <hostname>"
	exit 1
fi
hostname=$1

cat > ext.cnf.$$ <<EOM
[ leaf ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:FALSE
subjectAltName=DNS:$hostname
EOM

SUBJ='/C=NL/O=Ministerie van Volksgezondheid, Welzijn en Sport/OU=Corona Alerters/CN='.$hostname
$OPENSSL req -new -keyout x509.key -nodes -subj "${SUBJ}" |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions leaf \
	-req -CAkey sub-ca.key -CA sub-ca.pem -set_serial 0xdeadbeefdeadbeefc0de -out x509.pub
rm ext.cnf.$$

cat ca.pem sub-ca.pem  > full-chain.pem 
cat sub-ca.pem  > chain.pem 

openssl pkcs12 -export -out=server-$hostname.pfx -in x509.pub -inkey x509.key -certfile full-chain.pem -nodes -passout pass:corona2020

cat<<EOM
	
Generated
	x509.pem	pub key/cert for $hostname
	x509.key	private key
	$hostname.pfx	PKCS#12 / .p12 file with key, cert and chain up to the root ca.
			password:corona2020	

EOM
