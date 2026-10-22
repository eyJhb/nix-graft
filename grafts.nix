pkgs:
let
  inherit (pkgs) lib;

  # Another nixpkgs revision, for the same system and with the same config.
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

  files = lib.attrNames (
    lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (
      builtins.readDir ./grafts
    )
  );

  load =
    file:
    let
      name = lib.removeSuffix ".nix" file;
      grafts = lib.toList (import (./grafts + "/${file}") { inherit pkgs lib nixpkgsAt; });
    in
    map (
      graft:
      assert lib.assertMsg (
        graft ? reason && graft ? applies && graft ? old && graft ? new
      ) "graft ${name}: needs reason, applies, old and new";
      { id = name; } // graft // { file = name; }
    ) grafts;
in
lib.concatMap load files
