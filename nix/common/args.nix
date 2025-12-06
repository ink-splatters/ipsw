top @ {lib, ...}: let
  inherit (lib) optionals;
in {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) frida;

    compileFlags =
      top.config.build.compileFlags
      ++ optionals (frida.dev-kit != null) [
        "-I${top.config.src}/hack/frida-compat"
        "-I${frida.dev-kit}/include"
      ];

    linkFlags =
      top.config.build.linkFlags
      ++ optionals (frida.dev-kit != null) [
        "-L${frida.dev-kit}/lib"
        "-lfrida-core"
      ];
  in {
    options = {
      commonArgs = lib.mkOption {
        type = lib.types.attrs;
        default = {
          buildInputs = with pkgs;
            [
              libusb1
              unicorn
            ]
            ++ optionals pkgs.stdenv.hostPlatform.isDarwin [pkgs.apple-sdk_15]
            ++ optionals (frida.dev-kit != null) [frida.dev-kit];

          env.CGO_ENABLED = 1;

          nativeBuildInputs = with config.build;
          with llvm.packages; [
            clang
            bintools
            go
          ];

          CGO_CFLAGS = lib.concatStringsSep " " compileFlags;
          CGO_LDFLAGS = lib.concatStringsSep " " linkFlags;
          tags =
            ["unicorn"]
            ++ optionals (frida.dev-kit != null) ["frida"];
        };
      };
    };
  };
}
