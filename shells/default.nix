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
    "kicad"
    "minecraft"
    "rust"
    "threat-dragon"
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
