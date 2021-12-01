echo heh > infile
sed -e 's/e/a/' infile
echo bleh | sed 's/e/a/g'
sed -i "1p" /mnt/etc
