{lib, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: let
    inherit (pkgs) llvmPackages_latest buildGo126Module;
    inherit (inputs'.tailscale-go.packages) go_1_26;
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

          inherit go_1_26;
          buildGo126Module = buildGo126Module.override {
            inherit stdenv;
            go = go_1_26;
          };
        };
      };
    };
  };
}
