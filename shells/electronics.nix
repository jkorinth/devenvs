{ pkgs, pkgs-stable, ... }:
let
  kicad = pkgs.kicad.override { compressStep = false; };
  freecad = pkgs-stable.freecad;
  python = pkgs.python3.withPackages (
    pp: with pp; [
      ezdxf
      markdown
      pytest
      pyyaml
      typer
    ]
  );
  electronicsPackages =
    (with pkgs; [
      appimage-run
      ergogen
      findutils
      gerbv
      gh
      gnumake
      gtk3
      interactive-html-bom
      kicad
      kicadAddons.kikit
      python
      ruff
      saleae-logic-2
      xvfb-run
      zip
    ])
    ++ [ freecad ];
in
pkgs.mkShell {
  name = "electronics-dev";
  packages = electronicsPackages;

  shellHook = ''
        	  echo
        	  echo "=== Welcome to your wasted life playground! ==="
        	  echo
        	  echo "KiCAD: `${kicad}/bin/kicad-cli --version`"
        	  echo "KiKit: `${pkgs.kikit}/bin/kikit --version`"
        	  echo "ergogen: `${pkgs.ergogen}/bin/ergogen --version`"
        	  echo "ibom: `${pkgs.interactive-html-bom}/bin/generate_interactive_bom --version`"
        	  echo "FreeCAD: `${freecad}/bin/freecadcmd --version`"
        	  echo

        	  export KICAD10_FOOTPRINT_DIR="${kicad.libraries.footprints}/share/kicad/footprints"
        	  export KICAD10_3DMODEL_DIR="${kicad.libraries.packages3d}/share/kicad/3dmodels"
        	  export KICAD10_SYMBOL_DIR="${kicad.libraries.symbols}/share/kicad/symbols"
    	  export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-data-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-data-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
        	'';
}
