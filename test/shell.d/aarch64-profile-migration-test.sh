#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/home/.config/omarchy" "$work/profile"

profile_marker="$work/profile-marker"
repositories="$work/repositories.conf"
repository="$work/repository.conf"
package_log="$work/package.log"
shell_config="$work/home/.config/omarchy/shell.json"

touch "$profile_marker"
cat >"$repositories" <<'CONF'
stable=https://example.invalid/stable
rc=https://example.invalid/rc
edge=https://example.invalid/edge
source_url=https://example.invalid/source.git
source_branch=aarch64-quattro
CONF
cat >"$shell_config" <<'JSON'
{"custom":"kept"}
JSON
cat >"$work/profile/shell-defaults.jq" <<'JQ'
.profileApplied = true
JQ

cat >"$work/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$work/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_PROFILE_TEST_PACKAGE_LOG"
SH
chmod +x "$work/bin/sudo" "$work/bin/omarchy-pkg-add"

run_migration() {
  HOME="$work/home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_AARCH64_PROFILE="$profile_marker" \
    OMARCHY_AARCH64_REPOSITORIES="$repositories" \
    OMARCHY_AARCH64_REPOSITORY="$repository" \
    OMARCHY_SYSTEM_PROFILE_DIR="$work/profile" \
    OMARCHY_SHELL_CONFIG="$shell_config" \
    OMARCHY_PROFILE_TEST_PACKAGE_LOG="$package_log" \
    PATH="$work/bin:$ROOT/bin:$PATH" \
    bash "$ROOT/migrations/1788402490.sh" >/dev/null
}

run_migration
grep -Fxq 'source_branch=quattro' "$repositories" ||
  fail "AArch64 profile migration did not normalize the generated dev branch"
if grep -Fq 'source_branch=aarch64-quattro' "$repositories"; then
  fail "AArch64 profile migration retained the obsolete generated dev branch"
fi
grep -Fxq 'omarchy-aarch64-config' "$package_log" ||
  fail "AArch64 profile migration did not install the managed profile package"
jq -e '.custom == "kept" and .profileApplied == true' "$shell_config" >/dev/null ||
  fail "AArch64 profile migration did not apply the managed shell policy"
pass "AArch64 profile migration normalizes legacy state and applies managed policy"

sed -i 's/^source_branch=quattro$/source_branch=administrator-fork/' "$repositories"
: >"$package_log"
run_migration
grep -Fxq 'source_branch=administrator-fork' "$repositories" ||
  fail "AArch64 profile migration overwrote an administrator's source branch"
[[ $(wc -l <"$package_log") -eq 1 ]] ||
  fail "AArch64 profile migration is not repeatable"
pass "AArch64 profile migration preserves custom source branches and is repeatable"
