echo heh > infile
sed -e 's/e/a/' infile
echo bleh | sed 's/e/a/g'
# throw away status because /mnt/etc
# won't be available for the test
sed -i "1p" /mnt/etc || true
