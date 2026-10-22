#   CVE-2026-107891  regcomp: integer overflows lead to heap out-of-bounds writes
{ pkgs, lib, ... }:
let
  # The same patch nixpkgs adds (commit cefc7e9a).
  patch = pkgs.fetchurl {
    name = "CVE-2026-107891.patch";
    url = "https://www.openwall.com/lists/musl/2026/10/21/1/1";
    hash = "sha256-DPAJCrQz6PntCK4DoMk6/1V8HT40cmD2KmGhAoH1Mzs=";
  };

  # The fix doesn't change musl's version, so look for the patch itself.
  alreadyPatched = lib.any (p: (p.name or "") == patch.name) (pkgs.musl.patches or [ ]);
in
{
  reason = "CVE-2026-107891: integer overflows in musl's regcomp";
  advisory = "https://www.openwall.com/lists/musl/2026/10/21/1";
  cves = [ "CVE-2026-107891" ];
  applies = !alreadyPatched;
  old = pkgs.musl;
  new = pkgs.musl.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [ patch ];
  });
}
