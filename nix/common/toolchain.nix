{lib, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: let
    inherit (inputs'.tailscale-go.packages) go_1_26;
    inherit (pkgs.llvmPackages_latest) clang bintools stdenv;
  in {
    options = {
      stdenv = lib.mkOption {
        default = stdenv;
      };
      toolchain = lib.mkOption {
        type = lib.types.attrs;
        default = {
          inherit bintools clang;

          go = go_1_26;
          buildGoModule = pkgs.buildGo126Module.override {
            inherit stdenv;
            go = go_1_26;
          };
        };
      };
    };
  };
}
