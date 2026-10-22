rec {
  grafts = import ./grafts.nix;
  nixosModules.default = ./module.nix;

  # All replacements of all applicable grafts, including their `also` entries.
  replacements =
    pkgs:
    builtins.concatMap (
      g:
      map (r: {
        oldDependency = r.old;
        newDependency = r.new;
      }) ([ { inherit (g) old new; } ] ++ (g.also or [ ]))
    ) (builtins.filter (g: g.applies) (grafts pkgs));

  # Graft one package: apply pkgs pkgs.curl
  apply =
    pkgs: drv:
    pkgs.replaceDependencies {
      inherit drv;
      replacements = map (g: {
        oldDependency = g.old;
        newDependency = g.new;
      }) (builtins.filter (g: g.applies) (grafts pkgs));
      # don't warn about grafts that don't concern this package
      verbose = false;
    };

  # Graft several packages in one pass: env pkgs [ pkgs.curl pkgs.php84 ]
  env =
    pkgs: paths:
    apply pkgs (
      pkgs.buildEnv {
        name = "grafted";
        inherit paths;
      }
    );

  # Your pkgs, with every top-level package grafted on use: (packages pkgs).curl
  packages =
    pkgs:
    builtins.mapAttrs (
      name: value: if pkgs.lib.isDerivation value then apply pkgs value else value
    ) pkgs;

  # Readable summary of which grafts apply to this nixpkgs.
  report =
    pkgs:
    let
      inherit (pkgs) lib;
      all = grafts pkgs;
      active = builtins.filter (g: g.applies) all;
      inactive = builtins.filter (g: !g.applies) all;

      change =
        g:
        let
          o = lib.getVersion g.old;
          n = lib.getVersion g.new;
        in
        "${lib.getName g.old} ${o} → ${if o == n then "${n} (patched)" else n}";

      entry =
        g:
        lib.concatStringsSep "\n" (
          [
            "  ${g.id}"
            "    ${change g}"
            "    ${g.reason}"
          ]
          ++ lib.optional ((g.cves or [ ]) != [ ]) "    ${lib.concatStringsSep ", " g.cves}"
          ++ lib.optional (g ? advisory) "    ${g.advisory}"
        );
    in
    ''
      Active grafts (${toString (builtins.length active)}):
      ${lib.concatMapStringsSep "\n\n" entry active}

      Not needed, already fixed in your nixpkgs: ${
        if inactive == [ ] then "none" else lib.concatMapStringsSep ", " (g: g.id) inactive
      }
    '';
}
