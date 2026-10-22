rec {
  grafts = import ./grafts.nix;
  nixosModules.default = ./module.nix;

  # Grafts that apply to this nixpkgs, minus the ones excluded by id.
  active =
    pkgs: exclude: builtins.filter (g: g.applies && !(builtins.elem g.id exclude)) (grafts pkgs);

  # Replacement pairs of the active grafts, including `also`.
  # Warns about every graft with a warning, even ones that don't apply.
  replacements =
    pkgs: exclude:
    let
      inherit (pkgs) lib;

      # pkgs.brotli is only brotli's first output ("out"). Its library is in
      # brotli.lib, so split every pair into one pair per output.
      allOutputs =
        r:
        if lib.isDerivation r.old && lib.isDerivation r.new && r.old ? outputs then
          map (o: {
            old = r.old.${o};
            new = r.new.${o};
          }) (lib.filter (o: r.new ? ${o}) r.old.outputs)
        else
          [ r ];

      warnings = map (g: "graft ${g.id}: ${g.warning}") (
        builtins.filter (g: (g.warning or "") != "" && !(builtins.elem g.id exclude)) (grafts pkgs)
      );
    in
    lib.foldr lib.warn (builtins.concatMap (
      g:
      map (r: {
        oldDependency = r.old;
        newDependency = r.new;
      }) (builtins.concatMap allOutputs ([ { inherit (g) old new; } ] ++ (g.also or [ ])))
    ) (active pkgs exclude)) warnings;

  # Graft one package: apply pkgs pkgs.curl
  apply =
    pkgs: drv:
    pkgs.replaceDependencies {
      inherit drv;
      replacements = replacements pkgs [ ];
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
    pkgs: exclude:
    let
      inherit (pkgs) lib;
      all = grafts pkgs;
      used = active pkgs exclude;
      excluded = builtins.filter (g: g.applies && builtins.elem g.id exclude) all;
      fixed = builtins.filter (g: !g.applies) all;
      warned = builtins.filter (g: (g.warning or "") != "" && !(builtins.elem g.id exclude)) all;

      change =
        g:
        let
          o = lib.getVersion g.old;
          n = lib.getVersion g.new;
        in
        if g.insecure or false then
          "${lib.getName g.old} ${o}: marked insecure"
        else
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

      ids = gs: if gs == [ ] then "none" else lib.concatMapStringsSep ", " (g: g.id) gs;
    in
    ''
      Grafts for this nixpkgs (${toString (builtins.length used)}), applied where the package is used:
      ${lib.concatMapStringsSep "\n\n" entry used}

      Excluded on this machine: ${ids excluded}
      Not needed, already fixed in your nixpkgs: ${ids fixed}
      Warnings: ${
        if warned == [ ] then "none" else lib.concatMapStringsSep "\n  " (g: "${g.id}: ${g.warning}") warned
      }
    '';
}
