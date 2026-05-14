{
  pkgs,
  pkgs-stable,
  self,
  system,
  zephyr-nix,
  ...
}:
let
  shells = [
    "electronics"
    "rust"
    "typst"
    "zephyr"
    "zmk"
  ];
in
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = import ./${name}.nix {
      inherit
        self
        system
        pkgs
        pkgs-stable
        zephyr-nix
        ;
    };
  }) shells
)
