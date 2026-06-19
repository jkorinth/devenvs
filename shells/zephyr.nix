{
  system,
  pkgs,
  zephyr-nix,
  ...
}:
let
  zephyr = zephyr-nix.packages.${system};
in
pkgs.mkShell {
  name = "zephyr-dev";
  packages = with pkgs; [
    cmake
    dtc
    esptool
    gcc-arm-embedded
    gnumake
    gperf
    mbed-cli
    minicom
    ninja
    nrf-udev
    nrfutil
    openocd
    pkg-config
    SDL2
    saleae-logic-2
    screen
    zephyr.pythonEnv
    zephyr.hosttools
    (zephyr.sdkFull.override {
      targets = [
        "arm-zephyr-eabi"
      ];
    })
  ];

  shellHook = '''';
}
