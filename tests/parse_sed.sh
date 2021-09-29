echo heh > infile
sed -e 's/e/a/' infile
echo bleh | sed 's/e/a/g'
