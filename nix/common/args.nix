# common arguments, shared between dev and build
{lib, ...}: let
  inherit (lib) concatStringsSep mkOption optionals;
in {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) frida;

    CGO_CFLAGS = builtins.toString (optionals (frida.dev-kit != null) [
        "-I${frida.dev-kit}/include"
      ]
      ++ [
        "-Wall"
        "-pipe"
      ]);

    CGO_LDFLAGS = builtins.toString (optionals (frida.dev-kit != null) [
      "-L${frida.dev-kit}/lib -lfrida-core"
    ]);

    GOFLAGS = let
      mkTags = tags: ["-tags=${concatStringsSep "," tags}"];
    in
      mkTags (
        optionals (frida.dev-kit != null) [
          "frida"
        ]
        ++ [
          "unicorn"
          "sectrust_compat"
        ]
      );
  in {
    options = {
      commonArgs = mkOption {
        type = lib.types.attrs;
        default = {
          buildInputs = with pkgs;
            [
              libusb1
              unicorn
            ]
            ++ optionals config.stdenv.hostPlatform.isDarwin [pkgs.apple-sdk_15]
            ++ optionals (frida.dev-kit != null) [frida.dev-kit];

          env.CGO_ENABLED = 1;

          nativeBuildInputs = with config.toolchain; [
            clang
            bintools
            go_1_26
          ];

          inherit
            CGO_CFLAGS
            CGO_LDFLAGS
            ;
          env = {
            inherit GOFLAGS;
          };
        };
      };
    };
  };
}
