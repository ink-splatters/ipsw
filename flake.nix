{
  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:ink-splatters/nix-systems"; # no x86_64-darwin
    import-tree.url = "github:vic/import-tree";
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
    flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: let
      importTree = inputs.import-tree;
      systems = import inputs.systems;
      flakeModules.default = import ./nix {inherit importTree;};
    in {
      imports = [
        flakeModules.default
        flake-parts.flakeModules.partitions
      ];

      options = {
        src = lib.mkOption {
          type = lib.types.path;
          default = builtins.path {
            path = ./.;
            name = "ipsw";
          };
        };
      };

      config = {
        inherit systems;

        partitionedAttrs = {
          apps = "dev";
          checks = "dev";
          devShells = "dev";
          formatter = "dev";
        };
        partitions.dev = let
          dev = import ./nix/dev {inherit importTree;};
        in {
          extraInputsFlake = ./nix/dev;
          module.imports = [dev];
        };

        perSystem = {config, ...}: {
          packages.default = config.packages.ipsw;
        };

        flake = {inherit flakeModules;};
      };
    });
}
