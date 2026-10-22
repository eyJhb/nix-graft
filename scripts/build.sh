#!/usr/bin/env bash
set -euo pipefail

rev="${1:?usage: $0 <nixpkgs-revision> <package>...}"
shift

out=$(nix-build --no-out-link "$(dirname "$0")/build.nix" --argstr rev "$rev" --argstr names "$*")

for name in "$@"; do
  readlink -f "$out/$name"
done
