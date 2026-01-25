{
  description = "Dev environments for common projects/languages.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        pythonEnv = pkgs.python3.withPackages (
          ps: with ps; [
            accessible-pygments
            adb-shell
            alabaster
            anyio
            anytree
            babel
            breathe
            build
            cbor
            cbor2
            certifi
            charset-normalizer
            click
            cmsis-pack-manager
            colorama
            cryptography
            docopt
            docutils
            doxmlparser
            exceptiongroup
            furo
            graphviz
            grpcio
            grpcio-tools
            h11
            idna
            imagesize
            importlib-metadata
            iniconfig
            intelhex
            jinja2
            jsonschema
            kconfiglib
            libclang
            lit
            lxml
            markdown-it-py
            markupsafe
            mdurl
            mercurial
            natsort
            networkx
            numpy
            packaging
            pandas
            paramiko
            pexpect
            pluggy
            prettytable
            protobuf
            psutil
            ptyprocess
            py
            pyasn1
            pycparser
            pycryptodome
            pyelftools
            pygments
            pykwalify
            pyparsing
            pyserial
            pyshark
            pyspinel
            pytest
            python-dateutil
            python-dotenv
            pyusb
            pyyaml
            requests
            rich
            roman-numerals-py
            ruamel-base
            ruamel-yaml
            scikit-base
            scipy
            selenium
            setuptools
            six
            sphinx
            sphinx-autobuild
            sphinx-copybutton
            sphinx-design
            sphinx-last-updated-by-git
            sphinx-notfound-page
            sphinx-reredirects
            sphinx-rtd-dark-mode
            sphinx-rtd-theme
            sphinx-sitemap
            sphinx-tabs
            sphinx-togglebutton
            sphinxcontrib-applehelp
            sphinxcontrib-devhelp
            sphinxcontrib-htmlhelp
            sphinxcontrib-jquery
            sphinxcontrib-jsmath
            sphinxcontrib-mermaid
            sphinxcontrib-plantuml
            sphinxcontrib-programoutput
            sphinxcontrib-qthelp
            sphinxcontrib-serializinghtml
            sphinxcontrib-svg2pdfconverter
            starlette
            statsmodels
            tensorflow
            termcolor
            tf-keras
            tomli
            types-ipaddress
            typing-extensions
            urllib3
            uvicorn
            watchfiles
            websockets
            west
            wheel
            zipp
          ]
        );
      in
      {
        devShells = {
          zephyr = pkgs.mkShell {
            name = "zephyr-dev";
            packages = with pkgs; [
              pythonEnv
              cmake
              dtc
              esptool
              gcc-arm-embedded
              gnumake
              gperf
              mbed-cli
              ninja
              openocd
              screen
            ];
          };
        };
      }
    );
}
