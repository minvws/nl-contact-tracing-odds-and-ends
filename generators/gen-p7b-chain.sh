#!/bin/sh
#
set -e

# Fetch from CA down.
curl -O http://cert.pkioverheid.nl/EVRootCA.cer
curl -O http://cert.pkioverheid.nl/KPN_PKIoverheid_Server_CA_2020.cer
curl -O http://cert.pkioverheid.nl/DomeinServerCA2020.cer

# Convert into PEM
for i in *.cer
do 
	openssl x509 -inform DER -in $i -out `basename $i .cer`.pem
done

# Create the requested file
#
openssl crl2pkcs7 -out chain.p7b -certfile EVRootCA.pem -certfile DomeinServerCA2020.pem -certfile KPN_PKIoverheid_Server_CA_2020.pem -nocrl -outform DER

# Verify that it validates against a 'random' cert
#
openssl pkcs7 -in chain.p7b -print_certs -inform DER > chain.pem
openssl verify -CAfile chain.pem www.pkioverheid.nl.pem

exit 0

