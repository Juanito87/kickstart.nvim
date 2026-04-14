#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
app_name="nvim-test"

cleanup() {
  rm -rf "$tmp_dir"
}

trap cleanup EXIT

mkdir -p "$tmp_dir/config/$app_name" "$tmp_dir/data" "$tmp_dir/state" "$tmp_dir/cache"
cp -R "$repo_root"/. "$tmp_dir/config/$app_name"

export NVIM_APPNAME="$app_name"
export XDG_CONFIG_HOME="$tmp_dir/config"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_STATE_HOME="$tmp_dir/state"
export XDG_CACHE_HOME="$tmp_dir/cache"

cd "$tmp_dir/config/$app_name"

nvim --headless \
  "+Lazy! sync" \
  "+lua require('tests.runner').run()" \
  +qa
