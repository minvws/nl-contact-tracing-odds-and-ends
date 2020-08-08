Will generally require

	openssl   (the real one, free/libressl is not complete enough)
	protoc	- protobuff compiler
	json_pp	- json pretty printer
	xxd	- hex/bin/ect converter
	base64	- base64 decoder/encoder

The scripts named 'zsh' need zsh - as they reply on printf/echo having the -n flag (which the bash build-in does not).

fetch-eks.sh
	Fetch all the ZIPs with TEKS from the CDN

check-manifest-eks-and-verify.zsh
	Validate all ZIPs with TEKS on the CDN

check-signature-gaen.sh
	check the signature/hmac on a post TEKs

check-posting.sh
	post a generated set of keys; will post keys with the date in them.

post-payloads.sh
	post one or more key files

check-eks.zsh
	given one or more blob hashes - fetch each and check signature. Also
	works for blobs that are no longer or not yet in the manifest.
	
gen-fake-pki-overheid.sh
	generate a fake PKI tree that looks a bit like the PKI overheid one
	for testing

gen-server-cert.sh
	use above to generate a TLS/SSL cert

gen-signing-cert.sh
	use above for generating a signing key

gen-unmanaged-gaen-as-cert.sh
	generate a GAEN unmanaged key - in a cert format useful for HSMs and
	windows truststores

gen-unmanaged-gaen.sh
	simply generate a plain GAEN umanged key without ado.
