# Prints the value of one field of a cardflow header, or nothing when the field is missing.
#
# Usage: awk -v field=ID -f header.awk FILE
#
# The header is the block between the first two "---" lines at the very top of a file. Each field is a line
# "FIELD: value", the value padded with spaces so that values align; the padding is not part of the value. A file
# that does not start with "---" has no header. Windows line endings and a leading UTF-8 byte order mark are ignored,
# because files edited on Windows often carry them.

{ sub(/\r$/, "") }

NR == 1 {
  sub(/^\357\273\277/, "")
  if ($0 != "---") exit
  next
}

$0 == "---" { exit }

index($0, field ":") == 1 {
  value = substr($0, length(field) + 2)
  sub(/^[ \t]+/, "", value)
  sub(/[ \t]+$/, "", value)
  print value
  exit
}
