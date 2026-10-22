# Unbound 1.26.2 security release:
#   CVE-2026-97206   DoQ path migration use-after-free (multi-threaded)
#   CVE-2026-50106   insecure NXDOMAIN under island trust anchor
#   CVE-2026-96405   DNS name pointer decompression DoS
#   CVE-2026-109125  cache poisoning via unwanted-reply-threshold side-channel
#   CVE-2026-35501   island trust anchor bypass via attacker NSEC
{ pkgs, lib, ... }:
let
  version = "1.26.2";
  src = pkgs.fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "unbound";
    tag = "release-${version}";
    hash = "sha256-2CcDPUwzBRjRFzkXVinc7N956Cieb5QSS3BqDfFGgz0=";
  };
  bump = p: p.overrideAttrs { inherit version src; };
in
{
  reason = "Unbound ${version} security release";
  advisory = "https://github.com/NLnetLabs/unbound/releases/tag/release-${version}";
  cves = [
    "CVE-2026-97206"
    "CVE-2026-50106"
    "CVE-2026-96405"
    "CVE-2026-109125"
    "CVE-2026-35501"
  ];
  applies = lib.versionOlder pkgs.unbound.version version;
  old = pkgs.unbound;
  new = bump pkgs.unbound;
  also = [
    {
      old = pkgs.unbound-with-systemd;
      new = bump pkgs.unbound-with-systemd;
    }
    {
      old = pkgs.unbound-full;
      new = bump pkgs.unbound-full;
    }
  ];
}
