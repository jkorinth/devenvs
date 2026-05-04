{ pkgs, ... }:

pkgs.mkShell {
  name = "rust-dev";
  packages = with pkgs; [
    openssl
    pkg-config
    rust-bin.beta.latest.default
  ];
}
