top @ {lib, ...}: let
  cfg = builtins.fromJSON (builtins.readFile ./config.json);
in {
  options = {
    version = lib.mkOption {
      type = lib.types.str;
    };
    vendorHash = lib.mkOption {
      type = lib.types.str;
    };

    build = {
      compileFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "-O3"
          "-flto=thin"
          "-Wall"
          "-pipe"
          "-mcpu=${top.config.build.native}"
        ];
      };
      linkFlags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "-flto=thin"
          "-Wl,-dead_strip"
          "-fuse-ld=lld"
        ];
      };
      native = lib.mkOption {
        type = lib.types.str;
        default = "native";
      };
    };

    frida = lib.mkOption {
      type = lib.types.submodule {
        options = {
          version = lib.mkOption {
            type = lib.types.str;
          };
          sources = lib.mkOption {
            type = lib.types.attrs;
          };
        };
      };
    };
  };
  config = {
    perSystem = {
      config,
      pkgs,
      ...
    }: {
      options = {
        frida = lib.mkOption {
          type = lib.types.submodule {
            options = {
              dev-kit = lib.mkOption {
                type = lib.types.nullOr lib.types.package;
                default = null;
              };
            };
          };
        };
        build = {
          llvm.packages = lib.mkOption {
            type = lib.types.attrs;
            default = pkgs.llvmPackages_latest;
          };

          go = lib.mkOption {
            type = lib.types.package;
            default = pkgs.go_1_27;
          };

          buildGoModule = lib.mkOption {
            type = lib.types.functionTo lib.types.package;
            default = pkgs.buildGo127Module.override {
              inherit (config.build) go;
              inherit (config.build.llvm.packages) stdenv;
            };
          };
        };
      };
    };

    inherit (cfg) version vendorHash frida;
  };
}
