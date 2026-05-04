{
  description = "Dev environments for common projects/languages.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";

    zephyr = {
      url = "github:zephyrproject-rtos/zephyr/v4.3.0";
      flake = false;
    };

    zephyr-nix = {
      url = "github:nix-community/zephyr-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zephyr.follows = "zephyr";
      };
    };
  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      rust-overlay,
      self,
      zephyr,
      zephyr-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config = {
            allowUnfree = true;
            segger-jlink.acceptLicense = true;
            permittedInsecurePackages = [
              "python3.13-ecdsa-0.19.1"
            ];
          };
        };
        devShells = import ./shells {
          inherit
            pkgs
            rust-overlay
            self
            system
            zephyr
            zephyr-nix
            ;
        };
      in
      {
        inherit devShells;
      }
    );
}
