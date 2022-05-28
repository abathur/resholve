# --execer 'cannot:${openssl.bin}/bin/openssl can:${openssl.bin}/bin/c_rehash'
execer = [
  /*
    This is the same verdict binlore will
    come up with. It's a no-op just to demo
    how to fiddle lore via the Nix API.
  */
  "cannot:${openssl.bin}/bin/openssl"
  # different verdict, but not used
  "can:${openssl.bin}/bin/c_rehash"
];

# --wrapper '${gnugrep}/bin/egrep:${gnugrep}/bin/grep'
wrapper = [
  /*
    This is the same verdict binlore will
    come up with. It's a no-op just to demo
    how to fiddle lore via the Nix API.
  */
  "${gnugrep}/bin/egrep:${gnugrep}/bin/grep"
];
