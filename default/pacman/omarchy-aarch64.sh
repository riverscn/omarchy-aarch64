OMARCHY_AARCH64_PROFILE=${OMARCHY_AARCH64_PROFILE:-/etc/omarchy-aarch64/profile}
OMARCHY_AARCH64_REPOSITORIES=${OMARCHY_AARCH64_REPOSITORIES:-/etc/omarchy-aarch64/repositories.conf}
OMARCHY_AARCH64_REPOSITORY=${OMARCHY_AARCH64_REPOSITORY:-/etc/pacman.d/omarchy-aarch64.conf}

omarchy_aarch64_active() {
  [[ -f $OMARCHY_AARCH64_PROFILE ]]
}

omarchy_aarch64_config_file() {
  if [[ -f $OMARCHY_AARCH64_REPOSITORIES ]]; then
    printf '%s\n' "$OMARCHY_AARCH64_REPOSITORIES"
  else
    printf '%s\n' "$OMARCHY_PATH/default/pacman/omarchy-aarch64-repositories.conf"
  fi
}

omarchy_aarch64_config_value() {
  local key="$1"
  local config value

  config=$(omarchy_aarch64_config_file)
  value=$(awk -F= -v key="$key" '
    $1 == key {
      sub(/^[^=]*=/, "")
      print
      exit
    }
  ' "$config")

  [[ -n $value && $value != *[[:space:]]* ]] || return 1
  printf '%s\n' "$value"
}

omarchy_aarch64_repository_url() {
  case "$1" in
    stable | rc | edge) omarchy_aarch64_config_value "$1" ;;
    *) return 1 ;;
  esac
}

omarchy_aarch64_active_channel() {
  local active channel candidate

  [[ -f $OMARCHY_AARCH64_REPOSITORY ]] || return 1
  active=$(sed -n 's/^[[:space:]]*Server[[:space:]]*=[[:space:]]*//p' "$OMARCHY_AARCH64_REPOSITORY" | head -n 1)
  [[ -n $active ]] || return 1

  for channel in stable rc edge; do
    candidate=$(omarchy_aarch64_repository_url "$channel") || continue
    if [[ $active == "$candidate" ]]; then
      printf '%s\n' "$channel"
      return 0
    fi
  done

  # Compatibility with images released before channel-specific URLs existed.
  if [[ $active == "https://github.com/riverscn/omarchy-pkgs-aarch64/releases/latest/download" ]]; then
    printf '%s\n' stable
    return 0
  fi

  return 1
}
