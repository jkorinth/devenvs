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
    "blog"
    "electronics"
    "rust"
    "typst"
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
