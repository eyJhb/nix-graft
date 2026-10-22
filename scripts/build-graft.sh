#!/usr/bin/env bash
# scripts/build-graft.sh <nixpkgs-revision> [graft-id-or-file]...
set -euo pipefail

rev="${1:?usage: $0 <nixpkgs-revision> [graft-id-or-file]...}"
shift

nix-build --no-out-link "$(dirname "$0")/build-graft.nix" --argstr rev "$rev" --argstr grafts "$*"
