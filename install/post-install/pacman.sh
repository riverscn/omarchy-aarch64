# Configure pacman after package installation completes. AArch64 uses Arch
# Linux ARM for its distribution repositories. The image layer adds the signed
# Omarchy AArch64 repository as a separate include and preserves that include
# through its pre-refresh-pacman hook.
case $(uname -m) in
  aarch64 | arm64)
    pacman_config=pacman-aarch64.conf
    mirrorlist=mirrorlist-aarch64
    ;;
  *)
    pacman_config="pacman-${OMARCHY_MIRROR:-stable}.conf"
    mirrorlist="mirrorlist-${OMARCHY_MIRROR:-stable}"
    ;;
esac

cp -f "$OMARCHY_PATH/default/pacman/$pacman_config" /etc/pacman.conf
cp -f "$OMARCHY_PATH/default/pacman/$mirrorlist" /etc/pacman.d/mirrorlist

# Wait for CUPS to own the file, the way omarchy-settings does, so pacman does
# not turn the override into a .pacnew during ISO package installation.
if [[ -f $OMARCHY_PATH/etc-overrides/cups-cups-files.conf && -f /etc/cups/cups-files.conf ]]; then
  install -m 0640 -o root -g cups "$OMARCHY_PATH/etc-overrides/cups-cups-files.conf" /etc/cups/cups-files.conf
  rm -f /etc/cups/cups-files.conf.pacnew
fi

source "$OMARCHY_INSTALL/hardware/pacman.sh"
