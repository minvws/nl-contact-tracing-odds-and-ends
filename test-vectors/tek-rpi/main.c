//
//  main.cpp
//
// Copyright 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
// Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
// SPDX-License-Identifier: EUPL-1.2
//
//  Created by Dirk-Willem van Gulik on 19/09/2020.
//

// #include <iostream>

#include <time.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <err.h>

#include "gaen.h"

int main(int argc, const char * argv[]) {
    struct tm someday = { .tm_sec = 0, .tm_hour = 0, .tm_min = 0, .tm_mon=3, .tm_mday = 2, .tm_year = 2020 - 1900 };
    tek_t tek =  {0x75,0xc7,0x34,0xc6,0xdd,0x1a,0x78,0x2d,0xe7,0xa9,0x65,0xda,0x5e,0xb9,0x31,0x25};
    uint8_t transmitLevel = 8;
    metadata_t metadata;
    
    int j = 1;
    
    if (j) {
        someday.tm_mon = arc4random_uniform(12);
        someday.tm_mday= 1+arc4random_uniform(28);
        someday.tm_year =arc4random_uniform(5) + 2020 - 1900;
    };

    char fname[128];
    snprintf(fname,sizeof(fname),"test-%04d-%02d-%02d.txt",someday.tm_year+1900, someday.tm_mon+1, someday.tm_mday);
    
    stdout = fopen(fname,"w");
    printf("// File: %s\n",fname);
    
    time_t time = timegm(&someday);
    if (j) {
        arc4random_buf((unsigned char *)tek, 16);
    };
        
    printf("// Inputs \n");
    printf("%lu// time since epoch in seconds\n", time);
    printhex(tek,16); printf(" // TEK\n");
    
    if (j)
        transmitLevel =3 +arc4random_uniform(6);
    
    fillMetadata(metadata, transmitLevel);
    printhex(metadata,4); printf(" // Metadata\n");
    
    printf("\n// Derived intermediate values\n");
    
    interval_t interval = time2interval(time);
    printf("%u// Interval count\n", interval);
    
    rpik_t rpik;
    fillRpik(rpik, tek);
    printhex(rpik,16); printf(" // RPIK\n");
    
    aemk_t aemk;
    fillAemk(aemk, tek);
    printhex(aemk,16); printf(" // AEMK\n");
    
    printf("\n// Broadcasted values, from mid night on\n");
    printf("// RMI_ij                                        AEM_j\n");
    for(int i = 0; i < 144; i++) {
        
        rpiij_t rpiij;
        fillRpiij(rpiij,rpik,interval+i);
        printhex(rpiij,16); printf(" ");
        
        aem_t aem;
        fillAem(aem, aemk, rpiij, metadata);
        printhex(aem,4);
        
        time_t t = interval2time(interval+i);
        if (j)
            printf(" // Bcast from %s", asctime(gmtime(&t)));
        else
            printf("\n");
    };
    
    fclose(stdout);
    
    return 0;
}
