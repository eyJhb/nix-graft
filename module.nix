{
  config,
  lib,
  pkgs,
  ...
}:
let
  nixGrafts = import ./default.nix;
in
{
  options.grafts.enable = lib.mkEnableOption "security grafts" // {
    default = true;
  };

  config = lib.mkIf config.grafts.enable {
    system.replaceDependencies.replacements = nixGrafts.replacements pkgs;
    environment.etc."grafts.txt".text = nixGrafts.report pkgs;
  };
}
