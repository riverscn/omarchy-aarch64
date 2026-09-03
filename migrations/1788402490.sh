echo "Keep the AArch64 repository profile aligned across updates"

source "$OMARCHY_PATH/default/pacman/omarchy-aarch64.sh"

omarchy_aarch64_active || exit 0

# Early channel previews used a branch name that is now retained only as a
# remote compatibility alias. Change exactly that generated value and leave an
# administrator's custom source branch alone.
if [[ -f $OMARCHY_AARCH64_REPOSITORIES ]] &&
  grep -qx 'source_branch=aarch64-quattro' "$OMARCHY_AARCH64_REPOSITORIES"; then
  repositories_stage=$(mktemp)
  trap 'rm -f "$repositories_stage"' EXIT
  sed 's/^source_branch=aarch64-quattro$/source_branch=quattro/' \
    "$OMARCHY_AARCH64_REPOSITORIES" >"$repositories_stage"
  sudo install -Dm644 "$repositories_stage" "$OMARCHY_AARCH64_REPOSITORIES"
fi

# The repository policy is a normal signed package so exclusion changes reach
# existing machines instead of being frozen into the image that installed them.
omarchy-pkg-add omarchy-aarch64-config
