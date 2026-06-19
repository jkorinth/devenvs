{
  pkgs,
  ...
}:
pkgs.mkShell {
  name = "blog";
  packages = with pkgs; [
    hugo
    nodejs
    tomlq
    jq
  ];

  shellHook = '''';
}
