#!/usr/bin/env bash
set -euo pipefail

rev="${1:?usage: $0 <nixpkgs-revision>}"

nix eval --raw --impure --expr "(import ./.).report (import (fetchTarball \"https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz\") { })"
