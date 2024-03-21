echo heh > infile
sed -e 's/e/a/' infile
# TODO: when you've got test scaffold support for error cases, add true e commands
# sed -e 'e echo'
echo bleh | sed 's/e/a/g'
echo blah | sed 's/.*:/,/;s/$/,/'
# throw away status because /mnt/etc
# won't be available for the test
sed -i "1p" /mnt/etc || true
