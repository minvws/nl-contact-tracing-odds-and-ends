/* Copyright 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 * Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 * SPDX-License-Identifier: EUPL-1.2
 * dirkx@apache.org
 */

#include "ms64_to_x962.h"

#include <openssl/bn.h>
#include <openssl/asn1t.h>

#include <stdlib.h>

#ifdef DMALLOC
#include "dmalloc.h"
#endif

/* ASN1 defintion (from RFC 5480, page 17
 *
 *    ECDSA-Sig-Value ::= SEQUENCE {
 *    r  INTEGER,
 *    s  INTEGER
 *  }
 */

typedef struct X962_st {
	ASN1_INTEGER *r;
	ASN1_INTEGER *s;
} X962;

ASN1_SEQUENCE(X962) =
{
        ASN1_SIMPLE(X962, r, ASN1_INTEGER),
        ASN1_SIMPLE(X962, s, ASN1_INTEGER)
} ASN1_SEQUENCE_END(X962);

DECLARE_ASN1_FUNCTIONS(X962)

IMPLEMENT_ASN1_FUNCTIONS(X962)

int ms64byte_to_x962(const unsigned char ms64[64], unsigned char ** out) 
{
	unsigned char *outp;
	BIGNUM 	*r = NULL, *s = NULL;
	X962   	*x962 = NULL;
	int 	len; /* not size_t as it may contain -1 on error. */
	int	e = -1;

	/* The .NET api returns the values as a big-endian ordered
         * array of 2x32 bytes. It does not strip leading zeros.
         */
	r = BN_bin2bn(ms64,32, NULL);
	s = BN_bin2bn(ms64+32,32, NULL);
	if (NULL == r || NULL == s)
		return -1;

        x962  = X962_new();
	if (NULL == x962)
		return -1;

	ASN1_INTEGER_free(x962->r);
	x962->r = BN_to_ASN1_INTEGER(r, NULL);

	ASN1_INTEGER_free(x962->s);
	x962->s = BN_to_ASN1_INTEGER(s, NULL);

 	if (NULL == x962->r || NULL == x962->s)
		goto free_and_exit;

	if (-1 ==(len = i2d_X962(x962, NULL)))
		goto free_and_exit;

	if (NULL == *out && NULL == (*out = (unsigned char *)malloc((size_t)len)))
		goto free_and_exit;

	outp = *out;

	if (i2d_X962(x962, &outp )<0)
		goto free_and_exit;

	e = len;
free_and_exit:
	if (r) BN_free(r);
	if (r) BN_free(s);
	if (x962) X962_free(x962);
	return e;
}
