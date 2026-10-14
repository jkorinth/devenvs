{ pkgs, ... }:
let
  vscode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = with pkgs.vscode-extensions; [
      mkhl.direnv
    ];
  };

  # Real executables on PATH rather than shell functions: functions defined
  # in shellHook only exist in a bash `nix develop` session - direnv's
  # `use flake` (or any non-bash login shell, e.g. zsh) doesn't carry them
  # across, only environment variables.
  mc-build = pkgs.writeShellScriptBin "mc-build" ''
    exec regolith run
  '';

  mc-update = pkgs.writeShellScriptBin "mc-update" ''
    : "''${MC_HOST:=mustafar}"
    : "''${MC_REMOTE:=/srv/minecraft}"
    : "''${MC_ADDON:=$(basename "$PWD")}"
    src=packs
    [ -d build/BP ] && [ -d build/RP ] && src=build
    if [ ! -d "$src/BP" ] || [ ! -d "$src/RP" ]; then
      echo "mc-update: no $src/BP + $src/RP here (cwd: $PWD)." >&2
      echo "Run this from the addon's own directory, e.g. it might be a" >&2
      echo "subdirectory of where you are now, not the repo root." >&2
      exit 1
    fi
    if [ -z "$(find "$src/BP" "$src/RP" -type f 2>/dev/null)" ]; then
      echo "mc-update: $src/BP and $src/RP exist but are empty, nothing to send." >&2
      echo "(if you're using regolith filters: its default config.json export target" >&2
      echo "is 'development', which writes into a local Minecraft install, not" >&2
      echo "build/BP+build/RP - set it to 'local' to get output here instead)" >&2
      exit 1
    fi
    rsync -av --delete "$src/BP/" "$MC_HOST:$MC_REMOTE/behavior_packs/$MC_ADDON/"
    rsync -av --delete "$src/RP/" "$MC_HOST:$MC_REMOTE/resource_packs/$MC_ADDON/"
  '';

  mc-restart = pkgs.writeShellScriptBin "mc-restart" ''
    : "''${MC_HOST:=mustafar}"
    exec ssh "$MC_HOST" sudo systemctl restart podman-minecraft.service
  '';
in
pkgs.mkShell {
  name = "minecraft-dev";
  packages = with pkgs; [
    blockbench
    regolith
    jq
    rsync
    openssh
    vscode
    mc-build
    mc-update
    mc-restart
  ];

  shellHook = ''
    export MC_HOST="''${MC_HOST:-mustafar}"
    export MC_REMOTE="''${MC_REMOTE:-/srv/minecraft}"
    export MC_ADDON="''${MC_ADDON:-$(basename "$PWD")}"

    echo
    echo "=== minecraft-dev ==="
    echo "MC_HOST=$MC_HOST  MC_REMOTE=$MC_REMOTE  MC_ADDON=$MC_ADDON"
    echo "mc-build   - compile with regolith (only if using filters)"
    echo "mc-update  - rsync packs to \$MC_HOST:\$MC_REMOTE"
    echo "mc-restart - restart the Bedrock server container"
    echo

    # Not on open-vsx/nixpkgs, so nix can't fetch them - install straight
    # from the real VS Code Marketplace into ~/.vscode/extensions instead.
    # Mutable (unlike a nix-bundled extension), so VS Code's own updater
    # manages them normally from here on.
    code --install-extension BlockceptionLtd.blockceptionvscodeminecraftbedrockdevelopmentextension >/dev/null 2>&1 || true
    code --install-extension mojang-studios.minecraft-debugger >/dev/null 2>&1 || true
  '';
}
