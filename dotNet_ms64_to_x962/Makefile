CFLAGS = -I/opt/local/include -Wall  -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wconversion 
LDFLAGS = -L/opt/local/lib
LIBS = -lcrypto

all: test-dump convert

convert: ms64_to_x962.o convert.o
	$(CC) $(CFLAGS)  $^ -o $@ $(LIBS) $(LDFLAGS)

test-dump: ms64_to_x962.o test.o
	$(CC) $(CFLAGS)  $^ -o $@ $(LIBS) $(LDFLAGS)

test: test-dump
	./test-dump | openssl asn1parse -i -inform DER
	./test-dump | openssl asn1parse -i -inform DER | diff -qw result.txt - && echo OK - prefix-zap works.

dmalloc: test-dump
	$(CC) $(CFLAGS) -DDMALLOC -DDMALLOC_FUNC_CHECK  $^ -o test-dmalloc $(LIBS) $(LDFLAGS) -ldmalloc
	DMALLOC_OPTIONS=log=logfile ./test-dmalloc
	cat logfile

valgrind: test-dump
	valgrind  --show-leak-kinds=all --leak-check=full ./test-dump

clean:
	$(RM) -f *.o logfile test-dmalloc convert test-dump
