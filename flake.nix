{
  description = "Dev environments for common projects/languages.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";

    zephyr35 = {
      url = "github:zephyrproject-rtos/zephyr/v3.5.0";
      flake = false;
    };

    zephyr41 = {
      url = "github:zephyrproject-rtos/zephyr/v4.1.0";
      flake = false;
    };

    zephyr43 = {
      url = "github:zephyrproject-rtos/zephyr/v4.3.0";
      flake = false;
    };

    zephyr-nix = {
      url = "github:nix-community/zephyr-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zephyr.follows = "zephyr41";
      };
    };

  };

  outputs =
    {
      flake-utils,
      nixpkgs,
      nixpkgs-stable,
      rust-overlay,
      self,
      zephyr35,
      zephyr41,
      zephyr43,
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
        pkgs-stable = import nixpkgs-stable {
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
        mkZephyrShell =
          zephyr-input:
          import ./shells/zephyr.nix {
            inherit
              system
              pkgs
              zephyr-nix
              zephyr-input
              ;
          };
        devShells =
          import ./shells {
            inherit
              pkgs
              pkgs-stable
              rust-overlay
              self
              system
              zephyr-nix
              ;
          }
          // {
            zephyr35 = mkZephyrShell zephyr35;
            zephyr41 = mkZephyrShell zephyr41;
            zephyr43 = mkZephyrShell zephyr43;
          };
      in
      {
        inherit devShells;
      }
    );
}
