# grafts/php-2026-10-22.nix
# PHP 8.2.35, 8.3.36, 8.4.27 and 8.5.12 security releases:
#   CVE-2026-109618  GHSA-w8hw-w9fx-j79w  Core: state corruption via bailout
#   CVE-2026-109619  GHSA-6wmf-4rv5-p3rp  Core: state corruption via bailout
# Both are in PHP's core, so only the core is swapped. Every PHP built from it,
# including pkgs.phpXY and Nextcloud's own, picks it up; extensions stay as they are.
{ pkgs, lib, ... }:

let
  # Newer nixpkgs no longer has every PHP branch (php82 is gone).
  available = attr: (builtins.tryEval (pkgs ? ${attr} && pkgs.${attr} ? version)).value;

  graft =
    attr: version: hash:
    lib.optional (available attr) {
      id = "php-2026-10-22-${attr}";
      reason = "PHP ${version} security release";
      advisory = "https://www.php.net/ChangeLog-8.php#${version}";
      cves = [
        "CVE-2026-109618"
        "CVE-2026-109619"
      ];
      applies = lib.versionOlder pkgs.${attr}.version version;
      old = pkgs.${attr}.unwrapped;
      new =
        (pkgs.${attr}.overrideAttrs {
          inherit version;
          src = pkgs.fetchurl {
            url = "https://www.php.net/distributions/php-${version}.tar.xz";
            inherit hash;
          };
        }).unwrapped;
    };
in
lib.concatLists [
  (graft "php82" "8.2.35" "sha256-Vze5hgH+WrG4xdsMgu0xWKy5KD7TCB/+L6/7msgUVeY=")
  (graft "php83" "8.3.36" "sha256-3VRpOqM0xcTXLprulrCCwkc3UKGKbB0QV4nJOjsWkv0=")
  (graft "php84" "8.4.27" "sha256-3Pk5I7Djjg1SUrJbeWUgtaR3YaCLNIi20LXREVdk0/A=")
  (graft "php85" "8.5.12" "sha256-CLwuuipYhlSt4TVxdKpka3YVVshi3aBng0XuKe1IEgk=")
]
