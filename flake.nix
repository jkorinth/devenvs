{
  description = "Dev environments for common projects/languages.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";

    zephyr = {
      url = "github:zephyrproject-rtos/zephyr/v4.3.0";
      flake = false;
    };

    zephyr-nix = {
      url = "github:nix-community/zephyr-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
	zephyr.follows = "zephyr";
      };
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      rust-overlay,
      zephyr-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
          config = {
            allowUnfree = true;
            segger-jlink.acceptLicense = true;
	    permittedInsecurePackages = [
                "python3.13-ecdsa-0.19.1"
            ];
          };
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
	    patool
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
            semver
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
	    tqdm
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

        libraryPath = pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
          pkgs.libusb1
          pkgs.udev
        ];

	zephyr = zephyr-nix.packages.${system};

	zephyrShell = pkgs.mkShell {
            name = "zephyr-dev";
            packages = with pkgs; [
              cmake
              dtc
              esptool
              gcc-arm-embedded
              gnumake
              gperf
              mbed-cli
              minicom
              ninja
              nrf-udev
              nrfutil
              openocd
              pythonEnv
              saleae-logic-2
              screen
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="${libraryPath}:$LD_LIBRARY_PATH"
            '';
          };
      in
      {
        devShells = {
	  zephyr-dev = zephyrShell;

          zmk-dev = pkgs.mkShell {
            name = "zmk-dev";
	    #inputsFrom = [ zephyrShell ];
            packages = with pkgs; [
	      adafruit-nrfutil
	      cmake
	      ninja
	      protobuf
	      (zephyr-nix.packages.${system}.sdk-0_16.override {
	        targets = [
		  "arm-zephyr-eabi"
	        ];
	        inherit lib;
	      })
	      zephyr.pythonEnv
              pythonEnv
	      zephyr.hosttools
	    ] ++ (with pkgs.python3Packages; [ uv pre-commit ]);

            shellHook = ''
              	      export PATH=$PATH:~/.local/bin
              	      uv tool install zmk --force
              	    '';
          };

          typst-dev = pkgs.mkShell {
            name = "typst-dev";
            packages = with pkgs; [
              typst
              typstyle
            ];
          };
        };
      }
    );
}
