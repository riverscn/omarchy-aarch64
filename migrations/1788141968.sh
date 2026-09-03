echo "Align AArch64 package repositories with the Omarchy update channels"

source "$OMARCHY_PATH/default/pacman/omarchy-aarch64.sh"

omarchy_aarch64_active || exit 0

template="$OMARCHY_PATH/default/pacman/omarchy-aarch64-repositories.conf"
hook_source="$OMARCHY_PATH/default/pacman/omarchy-aarch64-pre-refresh"
hook="$HOME/.config/omarchy/hooks/pre-refresh-pacman.d/omarchy-aarch64-repository"
include='Include = /etc/pacman.d/omarchy-aarch64.conf'
pacman_conf=/etc/pacman.conf
repositories_stage=$(mktemp)
repository_stage=$(mktemp)

cleanup() {
  rm -f "$repositories_stage" "$repository_stage"
}
trap cleanup EXIT

if [[ -f $OMARCHY_AARCH64_REPOSITORIES ]]; then
  cp "$OMARCHY_AARCH64_REPOSITORIES" "$repositories_stage"
else
  cp "$template" "$repositories_stage"
fi

active_server=""
if [[ -f $OMARCHY_AARCH64_REPOSITORY ]]; then
  active_server=$(sed -n 's/^[[:space:]]*Server[[:space:]]*=[[:space:]]*//p' "$OMARCHY_AARCH64_REPOSITORY" | head -n 1)
fi

active_channel=$(omarchy_aarch64_active_channel 2>/dev/null || true)
active_channel=${active_channel:-stable}

# Preserve an explicitly configured legacy stable provider. Known channel URLs
# are normalized to the channel-specific defaults from the managed template.
if [[ -n $active_server && $active_channel == stable &&
  $active_server != "https://github.com/riverscn/omarchy-pkgs-aarch64/releases/latest/download" ]]; then
  known_server=0
  for channel in stable rc edge; do
    if [[ $active_server == "$(omarchy_aarch64_repository_url "$channel" 2>/dev/null || true)" ]]; then
      known_server=1
      break
    fi
  done

  if (( ! known_server )); then
    sed -i "s|^stable=.*|stable=$active_server|" "$repositories_stage"
  fi
fi

for key in stable rc edge source_url source_branch; do
  value=$(awk -F= -v key="$key" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$repositories_stage")
  if [[ -z $value || $value == *[[:space:]]* ]]; then
    echo "  Invalid AArch64 repository mapping: $key" >&2
    exit 1
  fi
done

repository_url=$(awk -F= -v key="$active_channel" '$1 == key { sub(/^[^=]*=/, ""); print; exit }' "$repositories_stage")
cat >"$repository_stage" <<EOF
# Managed by Omarchy AArch64.
[omarchy]
SigLevel = Required
Server = $repository_url
EOF

sudo install -Dm644 "$repositories_stage" "$OMARCHY_AARCH64_REPOSITORIES"
sudo install -Dm644 "$repository_stage" "$OMARCHY_AARCH64_REPOSITORY"

if ! grep -qxF "$include" "$pacman_conf"; then
  sudo sed -i "0,/^\[core\]/s||$include\n\n[core]|" "$pacman_conf"
fi

install -Dm755 "$hook_source" "$hook"
