# grafts/openssl-CVE-2026-84782.nix
# CVE-2026-84782 (High): DTLS retransmits handshake messages from a stale
# buffer offset, leaking heap memory to the peer or crashing.
{ pkgs, lib, ... }:
let
  fix =
    {
      "3.5" = {
        fixed = "3.5.9";
        commit = "906cf0ef1c85ca40ce69163e9086d6d3fe292943";
      };
      "3.6" = {
        fixed = "3.6.5";
        commit = "a383dafdd754eb5b22bf45e37e1bff9d07277a58";
      };
    }
    .${lib.versions.majorMinor pkgs.openssl.version} or null;
in
{
  reason = "CVE-2026-84782: DTLS stale-buffer retransmission (OOB read)";
  applies = fix != null && lib.versionOlder pkgs.openssl.version fix.fixed;
  old = pkgs.openssl;
  new = pkgs.openssl.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ [
      (pkgs.fetchpatch {
        url = "https://github.com/openssl/openssl/commit/${fix.commit}.patch";
        hash = "sha256-ZSb9CUlam5K6TmRmb5Qd67ywUCbVuIEPAcHGDeDM2/k=";
      })
    ];
  });
}
