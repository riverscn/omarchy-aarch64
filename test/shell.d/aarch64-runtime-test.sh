#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

mise_work="$ROOT/install/user/mise-work.sh"
pacman_setup="$ROOT/install/post-install/pacman.sh"
hardware_setup="$ROOT/install/hardware/all.sh"
service_setup="$ROOT/install/config/enable-services.sh"
aur_update="$ROOT/bin/omarchy-update-aur-pkgs"
pacman_refresh="$ROOT/bin/omarchy-refresh-pacman"
reinstall_packages="$ROOT/bin/omarchy-reinstall-pkgs"
provision_owner="$ROOT/bin/omarchy-provision-owner"
aarch64_limine="$ROOT/default/limine/limine.conf"

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
if grep -Fq 'hardware/bluetooth.sh' <<<"$virt_branch"; then
  fail "virtual AArch64 setup still enables physical Bluetooth hardware"
fi
pass "virtual AArch64 bypasses physical-machine hardware setup"

grep -Eq 'cmdline: .* quiet splash .*initramfs_async=0' "$aarch64_limine" ||
  fail "the native AArch64 Limine entry does not enable the Omarchy boot splash"
pass "the native AArch64 Limine entry preserves the Omarchy boot experience"

grep -Fq '/usr/lib/systemd/system/power-profiles-daemon.service' "$service_setup" ||
  fail "virtual profiles cannot omit the physical-machine power service"
grep -Fq '/etc/omarchy-aarch64/managed-packages' "$aur_update" ||
  fail "AUR updates do not protect image-managed packages"
grep -Fq -- '--ignore "$ignore_csv"' "$aur_update" ||
  fail "the managed package exclusion is not passed to yay"
grep -Fq 'pacman-aarch64.conf' "$pacman_refresh" ||
  fail "refreshing pacman would replace ALARM with an x86 Omarchy channel"
grep -Fq 'managed-packages' "$reinstall_packages" ||
  fail "reinstalling defaults requests unavailable image-built packages"
grep -Fq 'OMARCHY_PROFILE_EXCLUSIONS:-/etc/omarchy-aarch64/excluded-packages' "$reinstall_packages" ||
  fail "reinstalling defaults would undo the VM profile's package exclusions"
pass "virtual images keep profile and image-managed package boundaries during updates"
