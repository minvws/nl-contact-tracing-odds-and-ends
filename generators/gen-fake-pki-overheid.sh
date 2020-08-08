#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-openssl}

# Create a 'staat der nederlanden' root certificate that looks like
# the real thing. 
#
if test -f ca.key; then
	echo You propably want to run this script only once.
	exit 1
fi

$OPENSSL req -x509 \
	-out ca.pem -keyout ca.key -nodes \
	-subj '/CN=Staat der Nederlanden Root CA - G3/O=Staat der Nederlanden/C=NL'

cat > ext.cnf.$$ <<EOM
[ subca ]
keyUsage = cRLSign, keyCertSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:TRUE
EOM

# Create the chain to a normal PKI leaf cert
#
$OPENSSL req -new -keyout sub-ca.key -nodes \
	-subj '/C=NL/O=Staat der Nederlanden/CN=Staat der Nederlanden Organisatie - Services G3' |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions subca \
	-req -CAkey ca.key -CA ca.pem -set_serial 1010 -out sub-ca.pem

rm ext.cnf.$$

cat ca.pem sub-ca.pem  > full-chain.pem 
cat sub-ca.pem  > chain.pem 

# Create the root cert to import into keychain - in all formats
#
openssl x509 -in ca.pem -out ca.crt -outform DER
openssl pkcs12 -export -out=ca.pfx -in ca.pem -cacerts -nodes -nokeys -passout pass:corona2020
openssl crl2pkcs7 -nocrl -certfile ca.pem -certfile sub-ca.pem -out chain.p7b

cat <<EOM
Generated files

- to import into browsers/validatio tools:
	ca.pem	PEM version of the root cert - for use with tools
	ca.cer	DER version of the root cert - for use with browsers
	ca.pfx	PKCS12 version - for use with trust stores. The password
		is corona2020
	chain.p7b	Bundle as used by the TEK signing code.

- files needed for the creation of server/signing certs

	sub-ca.pem	subCA  that can issue certs.
	sub-ca.key	key for above

Files not needed - but useful 

	ca.key		secret key for root.

EOM
