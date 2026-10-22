

# Get report for specific nixpkgs version

```bash
$ nix eval --raw --impure --expr '(import ./.).report (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/cd4ea8d57de16f4810bc5f14207bac45fbf19f67.tar.gz") { })'
```

# Build them all

```bash
$ nix-build -E '
    let
      pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/5b65c02b1cb213f3e30a1715e5c2c114cf8eecb4.tar.gz") { };
      grafts = builtins.filter (g: g.applies) (import ./grafts.nix pkgs);
    in
    pkgs.replaceDependencies {
      drv = pkgs.linkFarmFromDrvs "grafts-test" (map (g: g.old) grafts);
      replacements = map (g: { oldDependency = g.old; newDependency = g.new; }) grafts;
    }'
    ls -l result/

```
