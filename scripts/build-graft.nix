# scripts/build-graft.nix
# Builds the replacements of the given grafts (ids or file names),
# or of every graft that applies if none are given.
{
  rev,
  grafts ? "",
}:
let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz") { };
  inherit (pkgs) lib;

  wanted = lib.filter (x: x != "") (lib.splitString " " grafts);
  chosen = lib.filter (g: wanted == [ ] || lib.elem g.id wanted || lib.elem g.file wanted) (
    (import ../.).grafts pkgs
  );

  applying = lib.filter (
    g:
    lib.warnIf ((g.warning or "") != "") "${g.id}: ${g.warning}" (
      g.applies || lib.warn "${g.id} does not apply to this revision, skipping" false
    )
  ) chosen;
in
assert lib.assertMsg (chosen != [ ]) "no graft matches: ${grafts}";
lib.concatMap (g: [ g.new ] ++ map (r: r.new) (g.also or [ ])) applying
