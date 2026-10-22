# bind 9.20.30 security releases
{ pkgs, lib, ... }:
let
  minVersion = "9.20.23";
  version = "9.20.30";
in
{
  reason = "Bind ${version} security release";
  advisory = "https://downloads.isc.org/isc/bind9/cur/9.20/doc/arm/html/notes.html#notes-for-bind-9-20-30";
  cves = [
    "CVE-2026-19630"
    "CVE-2026-94300"
    "CVE-2026-96888"
    "CVE-2026-97313"
  ];

  applies =
    let
      pkgVersion = lib.getVersion pkgs.bind;
    in
    lib.versionAtLeast pkgVersion minVersion && lib.versionOlder pkgVersion version;

  old = pkgs.bind;
  new = pkgs.bind.overrideAttrs (
    finalAttrs: _: {
      inherit version;

      src = pkgs.fetchurl {
        url = "https://downloads.isc.org/isc/bind9/${version}/bind-${version}.tar.xz";
        hash = "sha256-nhRDpApyowJyy8MZbQIKay4mk3ERyD5Z4QHoLh47T+8=";
      };
    }
  );
}
