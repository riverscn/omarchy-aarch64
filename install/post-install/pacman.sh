# Configure pacman after package installation completes. AArch64 images use
# Arch Linux ARM directly and intentionally have no Omarchy binary repository;
# their Omarchy packages are built from source and baked into each image.
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

# omarchy-settings skips this override until cups-browsed is actually present
# to avoid pacman creating cups-browsed.conf.pacnew during ISO package install.
if [[ -f $OMARCHY_PATH/etc-overrides/cups-cups-browsed.conf && -d /etc/cups ]]; then
  cp -f "$OMARCHY_PATH/etc-overrides/cups-cups-browsed.conf" /etc/cups/cups-browsed.conf
  rm -f /etc/cups/cups-browsed.conf.pacnew
fi

source "$OMARCHY_INSTALL/hardware/pacman.sh"
