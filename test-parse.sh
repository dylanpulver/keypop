#!/bin/bash
# test-parse.sh — self-check for keypop_parse. No dialogs, no vault writes.
# Run: ./test-parse.sh
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=/dev/null
source "$DIR/keypop"   # sourcing only defines functions (dispatch is guarded)

blob='
# a comment line
export FOO=bar
BAZ="qux quux"
TOKEN=abc=def==
lower_ok=1
API_KEY=  spaced
this is not a key line
9BAD=starts-with-digit
QUOTED='\''single'\''
'
out="$(printf '%s' "$blob" | keypop_parse)"

fail=0
want() {  # want NAME VALUE
  local line; line="$(printf '%s\t%s' "$1" "$2")"
  if grep -qxF "$line" <<<"$out"; then echo "ok   $1=$2"; else echo "MISS $1=$2"; fail=1; fi
}
absent() {  # absent NAME
  local pat; pat="$(printf '^%s\t' "$1")"   # real tab, portable on BSD/GNU grep
  if grep -q "$pat" <<<"$out"; then echo "LEAK $1 should have been skipped"; fail=1; else echo "ok   skipped $1"; fi
}

want FOO bar
want BAZ "qux quux"          # surrounding double-quotes stripped
want TOKEN "abc=def=="       # split on first '=', rest of value survives
want lower_ok 1
want API_KEY spaced          # trailing whitespace trimmed
want QUOTED single           # surrounding single-quotes stripped
absent 9BAD                  # invalid env name (leading digit)
absent this                  # prose line without a valid KEY=

n="$(grep -c . <<<"$out")"
[ "$n" -eq 6 ] || { echo "COUNT expected 6 pairs, got $n"; fail=1; }

[ "$fail" -eq 0 ] && echo "PASS" || { echo "FAIL"; exit 1; }
