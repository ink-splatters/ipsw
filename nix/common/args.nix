# common arguments, shared between dev and build
{lib, ...}: let
  inherit (lib) mkOption optionals;
  inherit (builtins) toString;
in {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) frida;
    inherit (pkgs) go_1_26;

    CGO_CFLAGS = toString (optionals (frida.dev-kit != null) [
        "-I${frida.dev-kit}/include"
      ]
      ++ [
        "-Wall"
        "-pipe"
      ]);

    CGO_LDFLAGS = toString (optionals (frida.dev-kit != null) [
      "-L${frida.dev-kit}/lib -lfrida-core"
    ]);

    tags =
      optionals (frida.dev-kit != null) [
        "frida"
      ]
      ++ [
        "libusb"
        # "sandbox"       # enables new closed source functionality which we cannot build from public tree
        "sectrust_compat" # https://github.com/ink-splatters/darwin-sectrust-compat
        "unicorn"
        "wallpaper"
      ];
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
          inherit tags;

          nativeBuildInputs =
            (with pkgs; [
              go_1_26
              pkg-config
            ])
            ++ (with config.toolchain; [
              clang
              bintools
            ]);

          inherit
            CGO_CFLAGS
            CGO_LDFLAGS
            ;
        };
      };
    };
  };
}
