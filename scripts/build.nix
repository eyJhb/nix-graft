{ rev, names }:
let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz") { };
  package = name: pkgs.lib.getAttrFromPath (pkgs.lib.splitString "." name) pkgs;
in
(import ../.).apply pkgs (
  pkgs.linkFarm "grafted" (
    map (name: {
      inherit name;
      path = package name;
    }) (pkgs.lib.splitString " " names)
  )
)
