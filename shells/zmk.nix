{
  self,
  system,
  pkgs,
  zephyr-nix,
  ...
}:
pkgs.mkShell {
  name = "zmk-dev";
  inputsFrom = [ self.devShells.${system}.zephyr ];
  packages =
    with pkgs;
    [
      adafruit-nrfutil
      cmake
      ninja
      protobuf
    ]
    ++ (with pkgs.python3Packages; [
      uv
      pre-commit
    ]);

  shellHook = ''
    	      export PATH=$PATH:~/.local/bin
    	      uv tool install zmk --force
    	    '';
}
