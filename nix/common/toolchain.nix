{lib, ...}: {
  perSystem = {pkgs, ...}: let
    inherit
      (pkgs.llvmPackages_latest)
      bintools
      clang
      stdenv
      ;
    go = pkgs.go_1_26;
  in {
    options = {
      stdenv = lib.mkOption {
        default = stdenv;
      };
      toolchain = lib.mkOption {
        type = lib.types.attrs;
        default = {
          inherit go;

          nativeBuildInputs = [
            bintools
            clang
            go
          ];
          buildGoModule = pkgs.buildGo126Module.override {
            inherit go stdenv;
          };
        };
      };
    };
  };
}
