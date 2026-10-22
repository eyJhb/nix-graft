{
  config,
  lib,
  pkgs,
  ...
}:
let
  nixGrafts = import ./default.nix;
  cfg = config.grafts;
in
{
  options.grafts = {
    enable = lib.mkEnableOption "security grafts" // {
      default = true;
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "2026-10-22-php-php84" ];
      description = "Ids of grafts not to apply on this machine.";
    };
  };

  config = lib.mkIf cfg.enable {
    system.replaceDependencies.replacements = nixGrafts.replacements pkgs cfg.exclude;

    # Don't graft the package manager itself.
    system.replaceDependencies.cutoffPackages = [ config.nix.package ];

    environment.etc."grafts.txt".text = nixGrafts.report pkgs cfg.exclude;

    warnings = map (id: "grafts.exclude: there is no graft with id ${id}") (
      lib.filter (id: !(builtins.elem id (map (g: g.id) (nixGrafts.grafts pkgs)))) cfg.exclude
    );
  };
}
