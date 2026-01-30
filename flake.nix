{
  inputs = {
    # module system for nix flakes
    # https://flake.parts
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    tailscale-go = {
      url = "github:ink-splatters/tailscale-go/go1.26rc2+20260130";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    nixpkgs.url = "github:NixOS/nixpkgs/70801e06d9730c4f1704fbd3bbf5b8e11c03a2a7";
    systems.url = "github:nix-systems/default";
  };

  nixConfig = {
    extra-substituters = [
      "https://aarch64-darwin.cachix.org"
    ];
    extra-trusted-public-keys = [
      "aarch64-darwin.cachix.org-1:mEz8A1jcJveehs/ZbZUEjXZ65Aukk9bg2kmb0zL9XDA="
    ];
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (let
      systems = import inputs.systems;
      flakeModules.default = import ./nix/flake-module.nix;
    in {
      imports = [
        flakeModules.default
        flake-parts.flakeModules.partitions
      ];

      inherit systems;

      partitionedAttrs = {
        apps = "dev";
        checks = "dev";
        devShells = "dev";
        formatter = "dev";
      };
      partitions.dev = {
        extraInputsFlake = ./nix/dev;
        module = {
          imports = [./nix/dev];
        };
      };

      perSystem = {
        config,
        lib,
        ...
      }: {
        options = {
          # used to avoid relative paths with parent references
          src = lib.mkOption {
            default = builtins.path {
              path = ./.;
              name = "ipsw";
            };
          };
        };
        config.packages.default = config.packages.ipsw;
      };

      # exports
      flake = {
        inherit flakeModules;
      };
    });
}
