pkgs:
let
  inherit (pkgs) lib;

  # Helper function to get another nixpkgs revision, for the same
  # system and with the same config. Might be moved in the future.
  nixpkgsAt =
    rev: sha256:
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        inherit sha256;
      })
      {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };

  # read all grafts from filesystem
  files = lib.attrNames (
    lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (
      builtins.readDir ./grafts
    )
  );

  # load/validate all grafts
  load =
    file:
    let
      name = lib.removeSuffix ".nix" file;
      grafts = lib.toList (import (./grafts + "/${file}") { inherit pkgs lib nixpkgsAt; });
      validated =
        graft:
        assert lib.assertMsg (
          graft ? reason && graft ? applies && graft ? old && graft ? new
        ) "graft ${name}: needs reason, applies, old and new";
        graft;
    in
    map (graft: { id = name; } // (validated graft) // { file = name; }) grafts;
in
lib.concatMap load files
