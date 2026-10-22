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

    includeReport = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Place grafts report at /etc/grafts.txt";
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

    # do not graft package manager itself, as it might cause issues
    system.replaceDependencies.cutoffPackages = [ config.nix.package ];

    environment.etc."grafts.txt".text = lib.optionalString cfg.includeReport (
      nixGrafts.report pkgs cfg.exclude
    );

    # warn if they are excluding grafts that does not exists
    warnings =
      let
        knownIds = map (g: g.id) (nixGrafts.grafts pkgs);
        unknownIds = lib.subtractLists knownIds cfg.exclude;
      in
      map (id: "grafts.exclude: there is no graft with id ${id}") unknownIds;
  };
}
