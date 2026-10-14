{
  system,
  pkgs,
  zephyr-input,
  zephyr-nix,
  # Existing zephyr35/41/43 shells rely on an external, manually-built SDK
  # (see zmk-config's .envrc); keep that behavior unchanged by default and
  # only pull the matching SDK into the shell itself when asked to.
  includeSdk ? false,
  sdkTargets ? [ "arm-zephyr-eabi" ],
  # zephyr-nix's pythonEnv tries to build a venv matching the *full*
  # scripts/requirements-base.txt, including spdx-python-model (used only
  # for SBOM generation), which isn't packaged in nixpkgs and makes the
  # whole derivation unevaluable (not just unbuildable) as of this writing.
  # Set this for Zephyr sources where that's the case: it swaps in a
  # hand-picked set of what `west build`/zephyr's cmake/kconfig scripts
  # actually need at build time, instead of zephyr-nix's pythonEnv.
  useMinimalPython ? false,
  ...
}:
let
  zephyr = zephyr-nix.packages.${system};
  zephyr-python =
    if useMinimalPython then
      # Mirrors scripts/requirements-base.txt, minus spdx-python-model
      # (unpackaged in nixpkgs, only used for SBOM generation).
      pkgs.python3.withPackages (ps: with ps; [
        west
        pyyaml
        pyelftools
        pykwalify
        jsonschema
        canopen
        packaging
        patool
        psutil
        pylink-square
        pyserial
        requests
        semver
        tqdm
        reuse
        anytree
        tabulate
        intelhex
        colorama
        grpcio-tools
        protobuf
      ])
    else
      zephyr.pythonEnv.override(old: {
        extraPackages = ps: (old.extraPackages or (_: [])) ps ++ (with ps; [ grpcio-tools protobuf west ]);
      });
  sdk = zephyr.sdkFull.override { targets = sdkTargets; };
in
pkgs.mkShell {
  name = "zephyr-dev";
  packages = with pkgs; [
    SDL2
    cmake
    dtc
    esptool
    gcc-arm-embedded
    gnumake
    go-task
    gperf
    mbed-cli
    minicom
    ninja
    nrf-udev
    nrfutil
    openocd
    pkg-config
    protobuf
    saleae-logic-2
    screen
    zephyr.hosttools
    zephyr-python
  ] ++ pkgs.lib.optional includeSdk sdk;

  shellHook = ''
    export ZEPHYR_BASE=${zephyr-input}
    echo "zephyr shell: $ZEPHYR_BASE"
  '' + pkgs.lib.optionalString includeSdk ''
    export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
    export ZEPHYR_SDK_INSTALL_DIR=${sdk}
  '';
}
