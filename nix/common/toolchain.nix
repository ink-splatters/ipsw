# toolchain configuration, shared between dev and build
{lib, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: let
    inherit (pkgs) go_1_25 buildGo125Module;
    pkgs-2411 = inputs'.nixpkgs-2411.legacyPackages;
    inherit (inputs'.nixpkgs-2411.legacyPackages.llvmPackages_latest) bintools clang stdenv;
  in {
    options = {
      pkgs-2411 = lib.mkOption {
        default = pkgs-2411;
      };
      toolchain = lib.mkOption {
        type = lib.types.attrs;
        default = {
          # bintools is a nix wrapper for llvm binutils, we use it for lld linker
          inherit bintools clang;
          inherit pkgs-2411;

          # use latest go compiler, overriding the nixpkgs default (go_1_24)
          go = go_1_25;
          buildGoModule = buildGo125Module.override {inherit stdenv;};
        };
      };
    };
  };
}
