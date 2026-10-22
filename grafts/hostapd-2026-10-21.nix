#   CVE-2025-24912  RADIUS issue (https://jvn.jp/en/jp/JVN19358384/)
#                   Fixed in hostapd 2.12; backported as two patches.
{ pkgs, lib, ... }:
let
  patches = [
    (pkgs.fetchpatch {
      name = "CVE-2025-24912-1.patch";
      url = "https://w1.fi/cgit/hostap/patch/?id=726432d7622cc0088ac353d073b59628b590ea44";
      hash = "sha256-C1V+WiUnmQwAZcJdbZluOejv3fSu7wmS24OeBjply/o=";
    })
    (pkgs.fetchpatch {
      name = "CVE-2025-24912-2.patch";
      url = "https://w1.fi/cgit/hostap/patch/?id=339a334551ca911187cc870f4f97ef08e11db109";
      hash = "sha256-8NtSLj5ASnNZ9A2MdiSYoa1Fv+t/vmTX1JinfA/bI9Y=";
    })
  ];

  # The backport doesn't change the version, so look for the patch itself.
  alreadyPatched = lib.any (p: (p.name or "") == "CVE-2025-24912-1.patch") (
    pkgs.hostapd.patches or [ ]
  );
in
{
  reason = "CVE-2025-24912: RADIUS issue in hostapd";
  advisory = "https://jvn.jp/en/jp/JVN19358384/";
  cves = [ "CVE-2025-24912" ];
  applies = lib.versionOlder pkgs.hostapd.version "2.12" && !alreadyPatched;
  old = pkgs.hostapd;
  new = pkgs.hostapd.overrideAttrs (o: {
    patches = (o.patches or [ ]) ++ patches;
  });
}
