#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-openssl}

# ES256 (ECDSA p256) 
$OPENSSL ecparam -name secp256k1 -genkey -noout -out ec.key
$OPENSSL ec -in ec.key -pubout -out ec.pub
$OPENSSL ec -in ec.key -pubout -text

cat <<EOM
Generated

	ec.pub	file to sent to google/apple
	ec.key	file to use

EOM
