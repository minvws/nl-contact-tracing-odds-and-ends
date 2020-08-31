#!/bin/sh
parse() {
	(
	cat > /tmp/x
	cat /tmp/x | sed -e 's|\# *||g' -e 's|^|// |g'
	cat /tmp/x | sed -e 's|\#.*||g' | xxd -p -r  > /tmp/xn
	# cat /tmp/xn | hexdump -C | sed  -e 's|^|// |g'
	echo "// Expected output:"
	cat /tmp/xn  | ./convert | openssl asn1parse -inform DER | sed -e 's|^|//|'
	echo '//'
	echo '[InlineData("'`cat /tmp/xn | base64`'","'`cat /tmp/xn | ./convert | base64`'")]'
	) 2>/dev/null
}

(
echo \# Simple case - full length.
echo \# P
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo \# Q
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# Lots of prefixes
echo \# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 FF   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 FF 00   00 00 00 00 00 00 00 00 
) | parse


(
echo \# strip first, second normal
# P
echo 00 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
# Q
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip second, first normal
# P
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
# Q
echo 00 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip both
# P
echo 00 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
# Q
echo 00 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip first to almost nothing
# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
# Q
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip first to just one byte
# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 11
# Q
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip first to just one byte, but with topbit set.
# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 F1
# Q
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip first to just one bit
# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 01
# Q
echo 00 00 33 44 55 66 77 88   11 22 33 44 55 66 77 88
echo 11 22 33 44 55 66 77 88   11 22 33 44 55 66 77 88
) | parse

(
echo \# strip bot to just one bit
# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 01
# Q
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 01
) | parse

(
echo \# strip both to one topbit.
# P
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 80
# Q
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 F0
) | parse

(
echo \# positive set and negative
# P
echo 7f 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
# Q
echo 84 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
) | parse

(
echo \# ... the bits of the first octet and bit 8 of the second octet:
echo \# 1.  shall not all be ones and
echo \# 2.  shall not all be zero.
# P
echo FF F0 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
# Q
echo 03 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
) | parse

(
echo \# ... the bits of the first octet and bit 8 of the second octet:
echo \# 1.  shall not all be ones and
echo \# 2.  shall not all be zero.
# P
echo FF F0 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 FF
# Q
echo 03 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 FF
) | parse

(
# P
echo 80 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
# Q
echo 7F 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00 
echo 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
) | parse
