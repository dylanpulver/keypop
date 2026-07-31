#!/bin/bash
# test-behavior.sh — headless checks for check-first, --env mirror, and --import.
# Stubs the dialogs (ask_masked / osascript) so nothing pops. No real vault touched.
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=/dev/null
source "$DIR/keypop"   # sourcing only defines functions (dispatch is guarded)

fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: want [$3] got [$2]"; fail=1; fi }
has()   { if grep -q "^$2=" "$1"; then echo "ok   $3"; else echo "FAIL $3: $2 missing from $1"; fail=1; fi }
absent(){ if grep -q "^$2=" "$1"; then echo "FAIL $3: $2 present in $1"; fail=1; else echo "ok   $3"; fi }

# --- Test A: --env presence skips the dialog (no pop) ---
VAULT="$(mktemp)"; ENVF="$(mktemp)"
printf 'FOO=abc\n' > "$ENVF"
ask_masked() { echo "POPPED"; return 0; }   # if reached, we'd see a bogus save
outA="$(single_mode --env "$ENVF" FOO 2>&1)"
check "A: env-present key reported already set" "$outA" "already set: FOO (3 chars)"
absent "$VAULT" FOO "A: env-present key did NOT get written to vault"

# --- Test B: saving with --env mirrors into the project .env ---
VAULT="$(mktemp)"; ENVF="$(mktemp)"
ask_masked() { printf 'sekret'; return 0; }   # simulate user pasting "sekret" + Save
outB="$(single_mode --env "$ENVF" NEWKEY 2>&1)"
has "$VAULT" NEWKEY "B: saved to vault"
has "$ENVF"  NEWKEY "B: mirrored to project .env"
case "$outB" in *"also written to $ENVF: NEWKEY"*) echo "ok   B: reports the mirror";; *) echo "FAIL B: no mirror report"; fail=1;; esac

# --- Test C: --import loads missing keys, skips existing (no --force) ---
VAULT="$(mktemp)"; SRC="$(mktemp)"
printf 'EXISTING=old\n'  > "$VAULT"
printf 'EXISTING=new\nFRESH=xyz\n' > "$SRC"
osascript() { return 0; }   # confirm the import dialog
outC="$(import_mode "$SRC" 2>&1)"
has "$VAULT" FRESH "C: fresh key imported"
check "C: existing kept old value (not replaced)" "$(grep '^EXISTING=' "$VAULT" | tail -1)" "EXISTING=old"

# --- Test D: --import --force replaces existing ---
VAULT="$(mktemp)"; SRC="$(mktemp)"
printf 'EXISTING=old\n' > "$VAULT"
printf 'EXISTING=new\n' > "$SRC"
osascript() { return 0; }
import_mode "$SRC" --force >/dev/null 2>&1
check "D: --force replaced existing value" "$(grep '^EXISTING=' "$VAULT" | tail -1)" "EXISTING=new"

[ "$fail" -eq 0 ] && echo "PASS" || { echo "FAIL"; exit 1; }
