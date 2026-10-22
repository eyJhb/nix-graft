#!/usr/bin/env bash
set -euo pipefail

rev="${1:?usage: $0 <nixpkgs-revision>}"
root=$(realpath "$(dirname "$0")/..")

nix eval --raw --impure --expr "(import \"$root\").report (import (fetchTarball \"https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz\") { })"
