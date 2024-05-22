temp_dir="$(mktemp -d --suffix=resholve-tests-parse-msmtp)"
trap 'rm -rf -- "$temp_dir"' EXIT
config="$temp_dir/msmtprc"
email="$temp_dir/test.eml"
export MSMTPQ_LOG="$temp_dir/msmtpq_log"
export MSMTPQ_Q="$temp_dir/msmtpq_q"
# TODO: We can remove this next line once this Nixpkgs PR gets merged:
# <https://github.com/NixOS/nixpkgs/pull/296720>
export MSMTP_LOG="$MSMTPQ_LOG" MSMTP_QUEUE="$MSMTPQ_Q"

echo '
    account default
    host example.com
' > "$config"
echo -ne 'To: foo@example.org\r\n' > "$email"
echo -ne 'MIME-Version: 1.0\r\n' >> "$email"
echo -ne '\r\n' >> "$email"

< "$email" msmtp -PC "$config" --passwordeval=cat
< "$email" msmtp -PC "$config" --passwordeval cat
< "$email" msmtpq -PC "$config" --passwordeval=cat
< "$email" msmtpq -PC "$config" --passwordeval cat
# TODO: These commands are valid, but our parse doesn’t support them yet.
#< "$email" msmtp -PC "$config" --passwordeval=
#< "$email" msmtpq -PC "$config" --passwordeval=
