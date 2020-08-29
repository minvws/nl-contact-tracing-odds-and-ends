CFLAGS = -I/opt/local/include -Wall  -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wconversion 
LDFLAGS = -L/opt/local/lib
LIBS = -lcrypto

SRC = $(wildcard *.c)
OBJ = $(patsubst %.c, %.o, $(SRC))

EXEC=test-dump

all: $(EXEC)

$(EXEC): $(OBJ)
	$(CC) $(CFLAGS)  $^ -o $@ $(LIBS) $(LDFLAGS)

test: $(EXEC)
	./$(EXEC) | openssl asn1parse -i -inform DER
	./$(EXEC) | openssl asn1parse -i -inform DER | diff -qw result.txt - && echo OK

dmalloc: $(OBJ)
	$(CC) $(CFLAGS) -DDMALLOC -DDMALLOC_FUNC_CHECK  $^ -o test-dmalloc $(LIBS) $(LDFLAGS) -ldmalloc
	DMALLOC_OPTIONS=log=logfile ./test-dmalloc
	cat logfile

valgrind: $(EXEC)
	valgrind  --show-leak-kinds=all --leak-check=full  ./$(EXEC)
clean:
	$(RM) -f $(OBJ) logfile $(EXEC) test-dmalloc
