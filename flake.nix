{
  description = "Nix System Configuration Files";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-darwin.follows = "darwin";
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-garden = {
      url = "github:garden-io/homebrew-garden";
      flake = false;
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    kubelogin = {
      url = "github:int128/kubelogin";
      flake = false;
    };

    vim-tintin = {
      url = "github:LokiChaos/vim-tintin";
      flake = false;
    };
  };
  outputs =
    inputs @ { self
    , darwin
    , nixpkgs
    , nix-on-droid
    , ...
    }:
    let
      defaultUser = "adam";
      overlays = import ./overlays;
    in
    {
      apps =
        let
          darwinApps = nixpkgs.lib.genAttrs [ "aarch64-darwin" ]
            (system: {
              "switch" = {
                type = "app";
                program = "${self}/apps/darwin/switch";
              };
            });
        in
        darwinApps;

      darwinConfigurations =
        let
          defaultDarwinSystem = "aarch64-darwin";
          mkDarwinMachine =
            { user ? defaultUser
            , system ? defaultDarwinSystem
            , modules
            }:
            darwin.lib.darwinSystem {
              inherit system modules;
              specialArgs = (inputs // {
                inherit user system inputs;
              });
              pkgs = import nixpkgs {
                inherit system overlays;
                config.allowUnfree = true;
              };
            };
        in
        {
          "personal-macbook" = mkDarwinMachine {
            modules = [
              ./machines/personal-macbook.nix
            ];
          };
          "influx-macbook" = mkDarwinMachine {
            modules = [
              ./machines/influx-macbook.nix
            ];
          };
        };

      nixOnDroidConfigurations.default =
        let
          user = defaultUser;
          system = "aarch64-linux";
        in
        nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs =
            (inputs // {
              inherit user system inputs;
            });
          pkgs = import
            nixpkgs
            {
              inherit system overlays;
              config.allowUnfree = true;
              modules = [
                ./machines/android.nix
              ];
            };
        };
    };
}

