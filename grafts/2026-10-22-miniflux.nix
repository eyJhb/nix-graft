{ pkgs, lib, ... }:
let
  version = "2.3.4";
  installedVersion = lib.getVersion pkgs.miniflux;
in
{
  reason = "Miniflux ${version} security release";
  advisory = "https://github.com/miniflux/v2/releases/tag/${version}";
  applies = lib.versionAtLeast installedVersion "2.3.0" && lib.versionOlder installedVersion version;
  old = pkgs.miniflux;
  new = pkgs.miniflux.overrideAttrs {
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "miniflux";
      repo = "v2";
      tag = version;
      hash = "sha256-IUgl9SlzFus6mdmkzRk8I/teZlv1pZAOENCMLeAZdKY=";
    };
    vendorHash = "sha256-u/BWeI0kby5yIPKJnYP/E1xC/ILhd50Pr+jriOFq2qU=";
  };
}
