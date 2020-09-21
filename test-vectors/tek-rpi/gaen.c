//
//  gaen.c
//
// Copyright 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
// Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
// SPDX-License-Identifier: EUPL-1.2
//
//  Created by Dirk-Willem van Gulik on 19/09/2020.
//

#include "gaen.h"

#include <mbedtls/entropy.h>
#include <mbedtls/ctr_drbg.h>
#include <mbedtls/aes.h>
#include <mbedtls/md.h>
#include <mbedtls/sha256.h>
#include <mbedtls/hkdf.h>
#include <mbedtls/platform.h>

#ifdef __APPLE__
#include <machine/byte_order.h>
#define htole32(x) OSSwapHostToLittleInt32(x)
#else
#include <endian.h>
#endif

// https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ExposureNotification-CryptographySpecificationv1.2.pdf?1

#define DAYS (14)     // days to keep

#define EN_RPIK_KEY ((uint8_t *)"EN-RPIK" /* sans UTF8 bom */)
#define EN_RPIK_KEY_LEN ((size_t) 7)

#define EN_AEMK_KEY ((uint8_t *)"EN-AEMK" /* sans UTF8 bom */)
#define EN_AEMK_KEY_LEN ((size_t) 7)

// https://covid19-static.cdn-apple.com/applications/covid19/current/static/contact-tracing/pdf/ExposureNotification-BluetoothSpecificationv1.2.pdf?1
#define MAJOR_V (01)
#define MINOR_V (00)

time_t interval2time(interval_t interval) {
    return interval * TTL;
};

interval_t time2interval(time_t t) {
    interval_t this_rolling_period_i =  (interval_t) t / TTL / TEKRollingPeriod;
    this_rolling_period_i *= TEKRollingPeriod;
    return this_rolling_period_i;
}

void HKDF(uint8_t *out,  uint8_t * key, size_t keylen, uint8_t * info, size_t infolen, size_t outlen) {
    int ret = mbedtls_hkdf(mbedtls_md_info_from_type(MBEDTLS_MD_SHA256), NULL, 0, key, keylen, info, infolen, out, outlen);
    assert(ret == MBEDTLS_PLATFORM_STD_EXIT_SUCCESS);
}

void fillRpik(rpik_t rpik, tek_t tek) {
    HKDF(rpik, tek, 16, EN_RPIK_KEY, EN_RPIK_KEY_LEN, 16);
}

void fillAemk(aemk_t aemk, tek_t tek) {
    HKDF(aemk, tek, 16, EN_AEMK_KEY, EN_AEMK_KEY_LEN, 16);
}

void fillMetadata(metadata_t md, uint8_t powerlevel) {
    md[0] = 0 + (MAJOR_V<<6) + (MINOR_V<<5);
    md[1] = powerlevel;
    md[2] = 0;
    md[3] = 0;
}

void printhex(const uint8_t * buff, size_t l) {
    for(;l>0;l--)
    printf(" %02x",*buff++);
};

void snprintfhex(char * out, size_t n, const uint8_t * buff, size_t l) {
    char * p = out;
    *p = '\0';
    for(;l>0;l--) {
        if (strlen(out) + 4 > n) return;
        snprintf(p,4," %02x",*buff++);
        p += 3;
    };
};

void fillRpiij(rpiij_t rpiij, rpik_t rpik, interval_t ENINj) {
    mbedtls_aes_context ctx;
    int ret;
    uint8_t pad[16] = {
        'E', 'N', '-', 'R', 'P', 'I', // PaddedDataj[0...5] = UTF8("EN-RPI")
        0, 0, 0, 0, 0, 0, // addedDataj[6...11] = 0x000000000000
        0, 0, 0, 0        // PaddedDataj[12...15] = ENINj
    };
    mbedtls_aes_init (&ctx);
    
    // Note - this is in big endian order - and not in the normal
    // protocol/internet-interoperability Network order.
    //
    * (uint32_t*)(pad + 12) = htole32(ENINj);
    
    //Output ← AES128(Key, Data)
    //RPIi,j ← AES128(RPIKi,PaddedDataj)
    //
    ret = mbedtls_aes_setkey_enc (&ctx, rpik, 8 * 16 /* in bits */);
    assert(ret == MBEDTLS_PLATFORM_STD_EXIT_SUCCESS);

    ret = mbedtls_internal_aes_encrypt (&ctx, pad, rpiij);
    assert(ret == MBEDTLS_PLATFORM_STD_EXIT_SUCCESS);

    mbedtls_aes_free (&ctx);
}

void fillAem(aem_t aem, aemk_t aemk, rpik_t rpik, metadata_t metadata) {
    mbedtls_aes_context ctx;
    size_t nc_off = 0;
    unsigned char nonce_counter[16];
    int ret;

    memcpy(nonce_counter,rpik,16); // copy the rpik as it gets incremented.
    
    unsigned char stream_block[16];
    memset(stream_block, 0, sizeof(stream_block));

    // AES, Counter mode; RPI is the counter.
    //
    // Key:  AEMK_i
    // IV:   RPI_ij
    // Data: metadata
    //
    mbedtls_aes_init (&ctx);
    ret = mbedtls_aes_setkey_enc (&ctx, aemk, 8 * 16 /* in bits */);
    assert(ret == MBEDTLS_EXIT_SUCCESS);

    ret = mbedtls_aes_crypt_ctr (&ctx,
                           4 /* metadata len in bytes */,
                           &nc_off, // nonce offset
                           nonce_counter, // nonce counter (iv)
                           stream_block,
                           metadata, // data to encrypt
                           aem); // output
    assert(ret == MBEDTLS_EXIT_SUCCESS);

    mbedtls_aes_free (&ctx);
}
