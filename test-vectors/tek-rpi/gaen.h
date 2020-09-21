//
//  gaen.h
//
// Copyright 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
// Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
// SPDX-License-Identifier: EUPL-1.2
//
//  Created by Dirk-Willem van Gulik on 19/09/2020.
//

#ifndef gaen_h
#define gaen_h

#include <stdio.h>

#include <time.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>

typedef unsigned int    interval_t;

typedef uint8_t         tek_t[16];
typedef uint8_t         rpik_t[16];
typedef uint8_t         rpiij_t[16];
typedef uint8_t         tki_t[16];
typedef uint8_t         aem_t[16];
typedef uint8_t         aemk_t[16];
typedef uint8_t         metadata_t[4];

#define TTL (10 * 60) // 10 minutes
#define TEKRollingPeriod (144)


time_t interval2time(interval_t interval);
interval_t time2interval(time_t t);

void HKDF(uint8_t *out,  uint8_t * key, size_t keylen, uint8_t * info, size_t infolen, size_t outlen);

void fillRpik(rpik_t rpik, tek_t tek);
void fillAemk(aemk_t aemk, tek_t tek);
void fillRpiij(rpiij_t rpiij, rpik_t rpik, interval_t ENINj);
void fillMetadata(metadata_t md, uint8_t powerlevel);
void fillAem(aem_t aem, aemk_t aemk, rpik_t rpik, metadata_t metadata);

void printhex(const uint8_t * buff, size_t l);
void snprintfhex(char * out, size_t n, const uint8_t * buff, size_t l);
#endif /* gaen_h */
