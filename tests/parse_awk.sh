# 2 cases for issue 82
awk -F'\t' -vcategory="$1" '{ split($9, cs, "|");for (i in cs) if (cs[i] == category) { print; break; }; }'
awk -F'\t' -v category="$1" '{ split($9, cs, "|");for (i in cs) if (cs[i] == category) { print; break; }; }'
