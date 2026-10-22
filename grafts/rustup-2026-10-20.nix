# CVE-2026-111943    Distrust compromised intermediate certificates in crypto/x509
{ pkgs, lib, ... }:
let
  version = "1.29.2";
in
{
  reason = "CVE-2026-107891: Distrust compromised intermediate certificates in crypto/x509";
  advisory = "https://blog.rust-lang.org/2026/10/20/Rustup-1.29.2/";
  cves = [ "CVE-2026-111943" ];
  applies = lib.versionOlder pkgs.rustup.version version;
  old = pkgs.rustup;
  new = pkgs.rustup.overrideAttrs (
    finalAttrs: _: {
      inherit version;

      src = pkgs.fetchFromGitHub {
        owner = "rust-lang";
        repo = "rustup";
        tag = version;
        hash = "sha256-vtfZNMkUAmbdXv0sv7wdm62AjCkYJY188jLx8RrmO2M=";
      };

      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = "sha256-UL6nS3SbxKXFWftJLeFY622VQEyAimhNz+YJgZsLHJc=";
      };
    }
  );
}
