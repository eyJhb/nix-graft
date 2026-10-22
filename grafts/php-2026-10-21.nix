# grafts/php-2026-10-22.nix
# PHP 8.2.35, 8.3.36, 8.4.27 and 8.5.12 security releases:
#   CVE-2026-109618  GHSA-w8hw-w9fx-j79w  Core: state corruption via bailout
#   CVE-2026-109619  GHSA-6wmf-4rv5-p3rp  Core: state corruption via bailout
{ pkgs, lib, ... }:

let
  # ext/filter's OOM tests run `php-cgi -n`, assuming filter is built in;
  # nixpkgs builds it as a shared module, so load it explicitly.
  fixFilterTests = pfinal: pprev: {
    extensions = pprev.extensions // {
      filter = pprev.extensions.filter.overrideAttrs (old: {
        preCheck = (old.preCheck or "") + ''
          substituteInPlace \
            tests/oom_filter_input.phpt \
            tests/oom_filter_input_array.phpt \
            tests/oom_filter_default_encoded.phpt \
            --replace-fail "'-n'," "'-n', '-d', 'extension=$PWD/modules/filter.so',"
        '';
      });
    };
  };

  # Newer nixpkgs no longer has every PHP branch (php82 is gone).
  available = attr: (builtins.tryEval (pkgs ? ${attr} && pkgs.${attr} ? version)).value;

  # Modules like Nextcloud build their own PHP with .buildEnv/.withExtensions.
  # Those share PHP itself and its extensions, so graft those too.
  usable = d: (builtins.tryEval (lib.isDerivation d && d.outPath != "")).value;
  parts =
    old: new:
    [
      {
        old = old.unwrapped;
        new = new.unwrapped;
      }
    ]
    ++
      lib.mapAttrsToList
        (name: ext: {
          old = ext;
          new = new.extensions.${name};
        })
        (lib.filterAttrs (name: ext: usable ext && usable (new.extensions.${name} or null)) old.extensions);

  graft =
    attr: version: hash:
    lib.optional (available attr) (rec {
      id = "php-2026-10-22-${attr}";
      reason = "PHP ${version} security release";
      advisory = "https://www.php.net/ChangeLog-8.php#${version}";
      cves = [
        "CVE-2026-109618"
        "CVE-2026-109619"
      ];
      applies = lib.versionOlder pkgs.${attr}.version version;
      old = pkgs.${attr};
      # .override before .overrideAttrs, or packageOverrides is ignored.
      new = (pkgs.${attr}.override { packageOverrides = fixFilterTests; }).overrideAttrs {
        inherit version;
        src = pkgs.fetchurl {
          url = "https://www.php.net/distributions/php-${version}.tar.xz";
          inherit hash;
        };
      };
      also = parts old new;
    });
in
lib.concatLists [
  (graft "php82" "8.2.35" lib.fakeHash)
  (graft "php83" "8.3.36" "sha256-3VRpOqM0xcTXLprulrCCwkc3UKGKbB0QV4nJOjsWkv0=")
  (graft "php84" "8.4.27" "sha256-3Pk5I7Djjg1SUrJbeWUgtaR3YaCLNIi20LXREVdk0/A=")
  (graft "php85" "8.5.12" "sha256-CLwuuipYhlSt4TVxdKpka3YVVshi3aBng0XuKe1IEgk=")
]
