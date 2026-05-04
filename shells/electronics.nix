{ pkgs, ... }:
let
  electronicsPackages = with pkgs; [
    appimage-run
    ergogen
    findutils
    freecad
    gh
    gnumake
    interactive-html-bom
    kicad
    kicadAddons.kikit
    python3
    saleae-logic-2
  ];
  kicad = pkgs.kicad;
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
    	  echo "FreeCAD: `${pkgs.freecad}/bin/freecadcmd --version`"
    	  echo

    	  export KICAD10_FOOTPRINT_DIR="${kicad.libraries.footprints}/share/kicad/footprints"
    	  export KICAD10_3DMODEL_DIR="${kicad.libraries.packages3d}/share/kicad/3dmodels"
    	  export KICAD10_SYMBOL_DIR="${kicad.libraries.symbols}/share/kicad/symbols"
    	'';
}
