#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/profile" "$work/home/.config/omarchy"

cat >"$work/profile/shell-defaults.jq" <<'JQ'
.profileApplied = true
JQ
cat >"$work/home/.config/omarchy/shell.json" <<'JSON'
{"custom":"kept"}
JSON

HOME="$work/home" \
  OMARCHY_SYSTEM_PROFILE_DIR="$work/profile" \
  "$ROOT/bin/omarchy-apply-system-profile"

jq -e '.custom == "kept" and .profileApplied == true' \
  "$work/home/.config/omarchy/shell.json" >/dev/null ||
  fail "system profile application discarded user configuration"

before=$(sha256sum "$work/home/.config/omarchy/shell.json")
HOME="$work/home" \
  OMARCHY_SYSTEM_PROFILE_DIR="$work/profile" \
  "$ROOT/bin/omarchy-apply-system-profile"
after=$(sha256sum "$work/home/.config/omarchy/shell.json")
[[ $before == "$after" ]] || fail "system profile application is not idempotent"

pass "system profile policy applies idempotently while preserving user settings"
