/* Copyright 2020 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 * Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 * SPDX-License-Identifier: EUPL-1.2
 * dirkx@apache.org
 */

#include "ms64_to_x962.h"

#include <stdio.h>
#include <err.h>
#include <stdlib.h>

int	main(int argc, char **argv)
{
	const unsigned char ms64[64];
	unsigned char * out = NULL;

	if (argc != 1)
		errx(1,"Syntax: %s\n\t"\
			"Supply 64 byte Microsoft .NET formatted file stdin\n\t"\
			"Output on stdout.\n", argv[0]);

        size_t i = fread((void *)ms64, 1, 64, stdin);
        if (i != 64)
		errx(1,"Read of 64 raw bytes failed.");

	int len;
	if ((len = ms64byte_to_x962(ms64, &out)) < 0) 
		errx(1,"Conversion failed.");

	fprintf(stderr,"Writing %d bytes\n", len);

	size_t e =  fwrite(out, 1, (size_t) len, stdout);
	if (len != e)
		errx(1,"Writing to stdout failed (%d!=%zu)",len, e);

	// We need to free this - as we'd set it to NULL; so it got alloc()ed.
	free(out);

	return (0);
};
