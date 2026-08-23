{
  system,
  pkgs,
  zephyr-input,
  zephyr-nix,
  ...
}:
let
  zephyr = zephyr-nix.packages.${system};
  zephyr-python = zephyr.pythonEnv.override(old: {
    extraPackages = ps: (old.extraPackages or (_: [])) ps ++ (with ps; [ grpcio-tools protobuf west ]);
  });
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
