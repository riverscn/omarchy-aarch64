#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

mise_work="$ROOT/install/user/mise-work.sh"
pacman_setup="$ROOT/install/post-install/pacman.sh"
hardware_setup="$ROOT/install/hardware/all.sh"
service_setup="$ROOT/install/config/enable-services.sh"
aur_update="$ROOT/bin/omarchy-update-aur-pkgs"
pacman_refresh="$ROOT/bin/omarchy-refresh-pacman"
channel_version="$ROOT/bin/omarchy-version-channel"
channel_set="$ROOT/bin/omarchy-channel-set"
repositories="$ROOT/default/pacman/omarchy-aarch64-repositories.conf"
channel_migration="$ROOT/migrations/1788141968.sh"
profile_migration="$ROOT/migrations/1788402490.sh"
reinstall_packages="$ROOT/bin/omarchy-reinstall-pkgs"
provision_owner="$ROOT/bin/omarchy-provision-owner"
aarch64_limine="$ROOT/default/limine/limine.conf"
aarch64_limine_defaults="$ROOT/default/limine/default.conf"
uki_defaults="$ROOT/etc/limine-entry-tool.d/omarchy-uki.conf"

grep -Fq 'aarch64 | arm64) node_arch=arm64' "$mise_work" ||
  fail "offline provisioning does not map AArch64 to Node's arm64 archive"
grep -Fq 'linux-${node_arch}.tar.gz' "$mise_work" ||
  fail "offline provisioning still pins a single Node architecture"
pass "offline provisioning selects the native Node archive"

grep -Fq 'pacman-aarch64.conf' "$pacman_setup" ||
  fail "AArch64 post-install does not select its pacman configuration"
grep -q '^\[alarm\]$' "$ROOT/default/pacman/pacman-aarch64.conf" ||
  fail "AArch64 pacman configuration lacks the ALARM repository"
if grep -q '^\[omarchy\]$\|^\[multilib\]$' "$ROOT/default/pacman/pacman-aarch64.conf"; then
  fail "AArch64 pacman configuration contains an x86-only repository"
fi
pass "AArch64 uses the native Arch Linux ARM repositories"

grep -Fq 'OMARCHY_HARDWARE_PROFILE:-} == "aarch64-virt"' "$hardware_setup" ||
  fail "hardware setup has no explicit virtual AArch64 profile"
grep -Fq 'hardware/virtual-machine.sh' "$hardware_setup" ||
  fail "virtual AArch64 setup does not enable guest integration"
virt_branch=$(sed -n '1,/^fi$/p' "$hardware_setup")
if grep -Fq 'hardware/input-group.sh' <<<"$virt_branch"; then
  fail "virtual AArch64 setup restores the retired input-group grant"
fi
if grep -Fq 'hardware/bluetooth.sh' <<<"$virt_branch"; then
  fail "virtual AArch64 setup still enables physical Bluetooth hardware"
fi
pass "virtual AArch64 bypasses physical-machine hardware setup"

grep -Fxq 'ENABLE_UKI=yes' "$uki_defaults" ||
  fail "the packaged Omarchy configuration does not enable UKIs"
if grep -Eq '^(ENABLE_UKI|FIND_BOOTLOADERS)=' "$aarch64_limine_defaults"; then
  fail "AArch64 boot defaults override Omarchy's packaged UKI or bootloader discovery policy"
fi
if grep -Eq '^[[:space:]]*(protocol: linux|path: boot\(\):/Image|module_path:)' "$aarch64_limine"; then
  fail "AArch64 still carries a static kernel/initramfs Limine entry"
fi
grep -Fxq 'default_entry: 2' "$aarch64_limine" ||
  fail "the Limine menu no longer follows the upstream Omarchy default entry"
pass "AArch64 uses Omarchy's generated UKI boot entries and upstream Limine menu"

grep -Fq '/usr/lib/systemd/system/power-profiles-daemon.service' "$service_setup" ||
  fail "virtual profiles cannot omit the physical-machine power service"
grep -Fq '/etc/omarchy-aarch64/managed-packages' "$aur_update" ||
  fail "AUR updates do not protect image-managed packages"
grep -Fq -- '--ignore "$ignore_csv"' "$aur_update" ||
  fail "the managed package exclusion is not passed to yay"
grep -Fq 'omarchy_aarch64_repository_url "$channel"' "$pacman_refresh" ||
  fail "refreshing pacman does not map the selected AArch64 package channel"
for channel in stable rc edge; do
  grep -Eq "^${channel}=.*/aarch64-${channel}$" "$repositories" ||
    fail "the AArch64 $channel repository is not channel-isolated"
done
grep -Fq 'omarchy_aarch64_active_channel' "$channel_version" ||
  fail "the active AArch64 repository cannot be reported as an Omarchy channel"
grep -Fq 'source_branch=quattro' "$repositories" ||
  fail "the AArch64 dev checkout has no adapted source branch"
grep -Fq 'clone_args=(--branch "$source_branch" --single-branch)' "$channel_set" ||
  fail "the AArch64 dev channel still clones the unadapted upstream branch"
grep -Fq 'active_channel=${active_channel:-stable}' "$channel_migration" ||
  fail "the AArch64 channel migration does not safely default legacy users to stable"
grep -Fq 'releases/latest/download' "$channel_migration" ||
  fail "the AArch64 channel migration does not recognize the legacy stable endpoint"
grep -Fq "grep -qx 'source_branch=aarch64-quattro'" "$profile_migration" ||
  fail "the runtime migration can rewrite custom source branches"
grep -Fq 'omarchy-pkg-add omarchy-aarch64-config' "$profile_migration" ||
  fail "existing AArch64 users do not receive the managed runtime profile"
grep -Fq 'managed-packages' "$reinstall_packages" ||
  fail "reinstalling defaults requests unavailable image-built packages"
grep -Fq '/usr/share/omarchy/system/excluded-packages' "$reinstall_packages" ||
  fail "reinstalling defaults ignores updated package-managed profile exclusions"
grep -Fq 'if o.cmd_present("powerprofilesctl") then' \
  "$ROOT/default/hypr/autostart.lua" ||
  fail "the VM still starts a power-profile service it deliberately omits"
pass "virtual images keep repository and image-managed package boundaries during updates"
