{ pkgs, ... }:
let
  image = "threatdragon/owasp-threat-dragon:stable";
  container = "threat-dragon-dev";

  # Picks whichever container engine is already on the host (docker or
  # podman) instead of pulling one in via nixpkgs: it has to match the
  # host's daemon/rootless setup, which a nix-built binary can't provide.
  pickEngine = ''engine="''${CONTAINER_ENGINE:-$(command -v docker || command -v podman)}"'';

  # Real executables on PATH rather than shell functions: functions defined
  # in shellHook only exist in a bash `nix develop` session - direnv's
  # `use flake` (or any non-bash login shell, e.g. zsh) doesn't carry them
  # across, only environment variables.
  td-stop = pkgs.writeShellScriptBin "td-stop" ''
    set -euo pipefail
    ${pickEngine}
    exec "$engine" rm -f ${container}
  '';

  td-start = pkgs.writeShellScriptBin "td-start" ''
    set -euo pipefail
    : "''${THREAT_DRAGON_DIR:=$PWD/threat-models}"
    : "''${THREAT_DRAGON_PORT:=8080}"
    mkdir -p "$THREAT_DRAGON_DIR"
    ${pickEngine}

    if "$engine" ps --format '{{.Names}}' | grep -qx ${container}; then
      running_port="$("$engine" port ${container} 3000/tcp | cut -d: -f2)"
      echo "td-start: ${container} already running on http://localhost:''${running_port:-?}/"
      exit 0
    fi
    "$engine" rm -f ${container} >/dev/null 2>&1 || true

    # Dev-mode config: local-session storage needs no git provider OAuth
    # creds, just NODE_ENV=development plus throwaway signing keys (session
    # cookies only, nothing persisted across container restarts).
    envfile="$(mktemp)"
    trap 'rm -f "$envfile"' EXIT
    chmod 644 "$envfile" # container runs as non-root, needs read access
    key() { openssl rand -hex 16; }
    cat > "$envfile" <<EOF
    NODE_ENV=development
    SERVER_API_PROTOCOL=http
    ENCRYPTION_JWT_REFRESH_SIGNING_KEY=$(key)
    ENCRYPTION_JWT_SIGNING_KEY=$(key)
    ENCRYPTION_KEYS='[{"isPrimary": true, "id": 0, "value": "$(key)"}]'
    EOF

    "$engine" run -d --rm \
      --name ${container} \
      -p "$THREAT_DRAGON_PORT:3000" \
      -v "$envfile:/app/.env" \
      -v "$THREAT_DRAGON_DIR:/threat-models" \
      ${image} >/dev/null

    echo "td-start: OWASP Threat Dragon running at http://localhost:$THREAT_DRAGON_PORT/"
    echo "td-start: THREAT_DRAGON_DIR=$THREAT_DRAGON_DIR mounted at /threat-models in the container"
    echo "td-start: use the browser's 'Login to Local Session' save/open dialog pointed at that directory"
  '';
in
pkgs.mkShell {
  name = "threat-dragon-dev";
  packages = with pkgs; [
    openssl
    td-start
    td-stop
  ];

  shellHook = ''
    echo
    echo "=== threat-dragon-dev ==="
    echo "td-start - start the server (runs automatically below)"
    echo "td-stop  - stop and remove the container"
    echo

    td-start
  '';
}
