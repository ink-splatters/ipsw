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

    compileFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "-O3"
        "-flto=thin"
        "-Wall"
        "-pipe"
        "-mcpu=${top.config.native}"
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
    native = lib.mkOption {
      type = lib.types.str;
      default = "native";
    };
  };
  config = {
    perSystem = {
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
      };
    };

    inherit (cfg) version vendorHash frida;
  };
}
