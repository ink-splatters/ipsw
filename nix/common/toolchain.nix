{lib, ...}: {
  perSystem = {
    pkgs,
    ...
  }: let
    inherit (pkgs) go_1_26 llvmPackages_latest buildGo126Module;
    inherit (llvmPackages_latest) clang bintools stdenv;
  in {
    options = {
      stdenv = lib.mkOption {
        default = stdenv;
      };
      toolchain = lib.mkOption {
        type = lib.types.attrs;
        default = {
          inherit bintools clang;

          buildGo126Module = buildGo126Module.override {
            inherit stdenv;
            go = go_1_26;
          };
        };
      };
    };
  };
}
