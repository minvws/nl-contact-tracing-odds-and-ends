#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <openssl/x509.h>
#include <openssl/x509err.h>
#include <openssl/cms.h>
#include <openssl/bio.h>
#include <openssl/asn1.h>
#include <openssl/pkcs7.h>
#include <openssl/pkcs12.h>

// dirkx@webweaving.org - quick date extraction from DER 
// cms file - only displays the first signer!
//
static int dirkx_ASN1_TIME_to_tm(const ASN1_TIME *pTime, struct tm *pTm)
{
	const char * p = (const char *) pTime;
#define D2B(x) (((x)[0]-'0')*10+((x)[1] - '0'))

  pTm->tm_year = D2B(&(p[0]));
  if (pTm->tm_year < 50) pTm->tm_year += 2000;
  if (pTm->tm_year < 100) pTm->tm_year += 1900;
  pTm->tm_year -= 1900;

  pTm->tm_mon = D2B(&(p[2])) - 1;
  pTm->tm_mday = D2B(&(p[4]));
  pTm->tm_hour = D2B(&(p[6]));
  pTm->tm_min = D2B(&(p[8]));
  pTm->tm_sec = D2B(&(p[10]));
  pTm->tm_gmtoff = 0;
  pTm->tm_zone="GMT";

  // trick the other values in so we do not
  // have to recode leap years and skipped days.
  time_t t = mktime(pTm);
  gmtime_r(&t, pTm);

  return 1;
};

	
//200801052501Z

int main(int argc, char ** argv)
{
  if (argc != 2) {
	fprintf(stderr,"Syntax: %s <cmsfile>\n",argv[0]);
	exit(1);
};

  BIO *bio = BIO_new_file(argv[1], "r");

  CMS_ContentInfo *cms = d2i_CMS_bio(bio, NULL);
  STACK_OF(CMS_SignerInfo) *sis = CMS_get0_SignerInfos(cms);
  CMS_SignerInfo *si = sk_CMS_SignerInfo_value(sis, 0);  // <-- first signer only

  X509_ATTRIBUTE *xa = CMS_signed_get_attr(si, CMS_signed_get_attr_by_NID(si, NID_pkcs9_signingTime, -1));
  ASN1_TYPE *so = X509_ATTRIBUTE_get0_type(xa,0);

  if (!so) {
     printf("No date\n");
	exit(1);
};

  ASN1_TIME *t;
  switch (so->type) {
  case V_ASN1_UTCTIME:
    t= (ASN1_TIME *)so->value.utctime->data;
    break;
  case  V_ASN1_GENERALIZEDTIME:
    t = (ASN1_TIME *)so->value.generalizedtime->data;
    break;
  default:
    fprintf(stderr,"Cannot parse time - hardcoded 0,0 assumption does not hold.\n");
    exit(1);
    break;
  }

  struct tm tm;
  if (1==ASN1_TIME_to_tm(t,&tm))
	printf("%s",asctime(&tm));
  else if (1==dirkx_ASN1_TIME_to_tm(t,&tm))
	printf("%s",asctime(&tm));
  else
	  printf("%s\n", (char *)t);
  BIO_free(bio);

  exit(0);
}
