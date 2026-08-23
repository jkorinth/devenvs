{
  system,
  pkgs,
  zephyr-input,
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
    go-task
    gperf
    SDL2
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
    zephyr.pythonEnv
    /*
      (zephyr.sdkFull.override {
        targets = [
          "arm-zephyr-eabi"
        ];
      })
    */
  ];

  shellHook = ''
    echo export ZEPHYR_BASE=${zephyr-input}
    echo "zephyr shell: $ZEPHYR_BASE"
  '';
}
