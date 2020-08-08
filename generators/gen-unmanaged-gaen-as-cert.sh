#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-openssl}

$OPENSSL req -new -x509 \
	-newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
	-out gaen.pem -keyout gaen.key -nodes \
	-subj '/CN=gaen'

cat gaen.key gaen.pem | openssl ec         > gaen-key.priv
cat gaen.key gaen.pem | openssl ec -pubout > gaen-key.pub

openssl pkcs12 -in gaen.pem -inkey gaen.key -export -out gaen.pfx -nodes -password pass:corona2020

cat <<EOM

Files:

	gaen.pfx	for the truststore, password corona2020
	gaen.pem/key	x509 version of above

	gaen-key.priv/pub
			unmanaged/plain keys

Key to sent to google/apple:
EOM

# Extract the EC key from it - and turn it into a format you would sent to google to include in OS
#
openssl ec -in gaen-key.priv -text -pubout
