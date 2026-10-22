{ pkgs, lib, ... }:
let
  version = "1.4.4";
  system = pkgs.stdenvNoCC.hostPlatform.system;

  installedVersion = lib.getVersion pkgs.bun;
  tooOld = lib.versionOlder installedVersion "1.4";

  releases = {
    aarch64-darwin = {
      file = "bun-darwin-aarch64.zip";
      hash = "sha256-wkDX8My5DCY6hJ/NsJt+5iYw2SE0jtaq/ahrnVd7xRA=";
    };
    aarch64-linux = {
      file = "bun-linux-aarch64.zip";
      hash = "sha256-uqa7NvUdblhWHgK76oJQOKnfRU9nPW13bou/hvjHhQ4=";
    };
    x86_64-linux = {
      file = "bun-linux-x64-baseline.zip";
      hash = "sha256-4ERutVmVdy65iUvrrppr42jZhai5Jx7hJEhvmUbu3XY=";
    };
  };
in
{
  reason = "Bun ${version}: security fixes for TLS, WebSocket, the database clients and the package manager";
  advisory = "https://github.com/oven-sh/bun/releases/tag/bun-v${version}";
  applies = releases ? ${system} && !tooOld && lib.versionOlder installedVersion version;

  warning = lib.optionalString tooOld "Bun ${installedVersion} won't get this fix: Bun only fixes its newest release, and ${installedVersion} -> ${version} can't be grafted. Use a newer Bun, for example from nixos-unstable.";

  cves = [
    "CVE-2026-111943"
  ];

  old = pkgs.bun;
  new = pkgs.bun.overrideAttrs (old: {
    inherit version;

    passthru = old.passthru // {
      sources = lib.mapAttrs (
        _: r:
        pkgs.fetchurl {
          inherit (r) hash;
          url = "https://github.com/oven-sh/bun/releases/download/bun-v${version}/${r.file}";
        }
      ) releases;
    };

    # we override src using passthru
    __intentionallyOverridingVersion = true;

  });
}
