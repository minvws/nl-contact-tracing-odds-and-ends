/* Copyright 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 * Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 * SPDX-License-Identifier: EUPL-1.2
 * dirkx@apache.org
 */

#ifndef _ms64_to_x962
#define _ms64_to_x962

/* As it stands:
 *
 *       cert.GetECDsaPrivateKey().SignData(content, HashAlgorithmName.SHA256);
 *
 * returns a 64 byte array; which contains two 32 byte (256 bits) integers
 * concatenated back to back in big-endian/network order.
 *
 * Until the new System.Formats.Asn1 package and AsnWriter (or similar) is
 * introdued; we need to 'manually' create an X9.62 package. This format is 
 * defined in  X9.62-1998, "Public Key Cryptography For The Financial 
 * Services Industry:  The Elliptic Curve Digital Signature Algorithm (ECDSA)", 
 * January 7, 1999".
 *
 * Within the contect of an ECDSA and the OID of the signature algorithm;
 * http://oid-info.com/get/1.2.840.10045.4.3.2 ()ecdsa-with-SHA256 and
 ** and most easily found in  https://www.ietf.org/rfc/rfc3279.txt in section
 * 2.2.2 - the format meant is:
 *
 *       Dss-Sig-Value  ::=  SEQUENCE  {
 *              r       INTEGER,
 *              s       INTEGER
 *      }
 *
 * ms64byte_to_x962()
 * Input parameters:
 *    const unsigned char ms64[64]
 *		Opaque 64 byte array as returned by .NET its cert.GetECDsaPrivateKey.
 *    unsigned char ** out 
 *		Buffer to store the results; which can be up to 2x(32 + 2 + 1)+=72 
 *              bytes. If a NULL is passed; the function will malloc() a buffer of
 *              the right size and leave it to the caller to free the memory.
 * Return values:
 *    number of bytes used in the return buffer. Or the value -1 on error.
 */
int ms64byte_to_x962(const unsigned char ms64[64], unsigned char ** out);
#endif

