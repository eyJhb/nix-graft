{
  outputs = { self }: {
    lib = import ./default.nix;
    nixosModules.default = ./module.nix;
  };
}
