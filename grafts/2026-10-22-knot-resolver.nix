# Knot Resolver 6.5.1 + 5.7.9 Security Release
{ pkgs, lib, ... }:
let
  # list of patches that are now upstreamed, that we can drop
  upstreamed = [
    "logging-level-regression.patch"
    "musl-build-regression.patch"
  ];

  graft = arg: minVersion: version: hash: [
    {
      reason = "Knot Resolver ${version} security release";
      advisory = "https://gitlab.nic.cz/knot/knot-resolver/-/releases/v${version}";
      cves = [
      ];

      applies =
        let
          knotResolverVersion = lib.getVersion pkgs.${arg};
        in
        lib.versionAtLeast knotResolverVersion minVersion && lib.versionOlder knotResolverVersion version;

      old = pkgs.${arg};
      new = pkgs.${arg}.overrideAttrs (old: {
        inherit version;
        src = pkgs.fetchurl {
          url = "https://knot-resolver.nic.cz/release/knot-resolver-${version}.tar.xz";
          hash = hash;
        };

        patches = lib.filter (p: !(lib.elem (p.name or "") upstreamed)) (old.patches or [ ]);
      });
    }
  ];
in
lib.concatLists [
  (graft "knot-resolver_6" "6.5.0" "6.5.1" "sha256-OyoEYmwd+bQkIJYAJbyU4od3dE0xxWetuVgMNxiarpc=")
  (graft "knot-resolver_5" "5.7.6" "5.7.9" "sha256-NiczLb/DCMr604yOP+yzY1ooMIBAJFWQHFz7xLyE614=")
]
