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

    # Unreleased main (4.5.0-rc1 at the time this was pinned), pinned to the
    # exact commit that the upstream pca_series polinv-mask PR branch is
    # based on, so this shell stays reproducible rather than tracking main.
    zephyr45 = {
      url = "github:zephyrproject-rtos/zephyr/e35b686be50a224e381fd35174be9fcb1a4ddd37";
      flake = false;
    };

    zephyr-nix = {
      url = "github:nix-community/zephyr-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zephyr.follows = "zephyr41";
      };
    };

    # Separate zephyr-nix instance so hosttools/pythonEnv/SDK are built for
    # whatever zephyr45 requires (SDK 1.0.1) instead of the 0.17.x the main
    # zephyr-nix input above is pinned to via zephyr41.
    #
    # Deliberately NOT following our own `nixpkgs` here: zephyr-nix's newer
    # pyproject-nix/uv-python.nix chain (needed to build main's python venv)
    # requires nixpkgs packages our pinned nixpkgs-unstable doesn't have yet
    # (e.g. spdx-python-model). Let it use its own locked nixpkgs instead of
    # bumping the shared top-level nixpkgs input for every other shell.
    zephyr-nix-45 = {
      url = "github:nix-community/zephyr-nix";
      inputs.zephyr.follows = "zephyr45";
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
      zephyr45,
      zephyr-nix,
      zephyr-nix-45,
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
          { zephyr-nix' ? zephyr-nix, includeSdk ? false, useMinimalPython ? false }:
          import ./shells/zephyr.nix {
            inherit
              system
              pkgs
              zephyr-input
              includeSdk
              useMinimalPython
              ;
            zephyr-nix = zephyr-nix';
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
            zephyr35 = mkZephyrShell zephyr35 { };
            zephyr41 = mkZephyrShell zephyr41 { };
            zephyr43 = mkZephyrShell zephyr43 { };
            zephyr45 = mkZephyrShell zephyr45 {
              zephyr-nix' = zephyr-nix-45;
              includeSdk = true;
              useMinimalPython = true;
            };
          };
      in
      {
        inherit devShells;
      }
    );
}
