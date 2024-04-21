echo heh > infile
sed -e 's/e/a/' infile
# TODO: when you've got test scaffold support for error cases, add true e commands
# echo heh | sed -e 'e echo hah'
echo bleh | sed 's/e/a/g'
echo blah | sed 's/.*:/,/;s/$/,/'
# throw away status because /mnt/etc
# won't be available for the test
sed -i "1p" /mnt/etc || true

# extracted/simplified from pihole
sed -E -e "s,.*(query\\[A|DHCP).*,${COL_NC}&${COL_NC},"
# patched version of above that should actually parse
sed -E -e 's,.*(query\[A|DHCP).*,'"${COL_NC}&${COL_NC},"
