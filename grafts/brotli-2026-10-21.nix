# Brotli 1.2.1 Security Release
#   CVE-2026-111497  out-of-bounds write permits remote code execution
{ pkgs, lib, ... }:
let
  graft = minVersion: version: hash: [
    {
      reason = "Brotli ${version} security release";
      advisory = "https://github.com/google/brotli/releases/tag/v${version}";
      cves = [
        "CVE-2026-111497"
      ];

      applies =
        lib.versionAtLeast pkgs.brotli.version minVersion && lib.versionOlder pkgs.brotli.version version;

      old = pkgs.brotli;
      new = pkgs.brotli.overrideAttrs {
        inherit version;
        src = pkgs.fetchFromGitHub {
          owner = "google";
          repo = "brotli";
          tag = "v${version}";
          hash = hash;
        };
      };
    }
  ];
in
lib.concatLists [
  (graft "1.2.0" "1.2.1" "sha256-llY72cYffDv0ugsH0p89xIPEbElV4L8u7U/Fe8hT3gI=")
  (graft "1.0.0" "1.1.1" "sha256-pyZoEhszl3rAr7aRhB5FNo5STy0xiTqLhnu05Ui6yKY=")
]
