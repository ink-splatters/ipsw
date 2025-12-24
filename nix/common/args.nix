# common arguments, shared between dev and build
{lib, ...}: {
  perSystem = {config, ...}: let
    inherit (config) frida pkgs-2411;

    compileFlags = builtins.toString (
      lib.optionals (frida.dev-kit != null) ["-I${frida.dev-kit}/include"]
      ++ [
        "-isysroot ${pkgs-2411.apple-sdk_11}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
      ]
    );
    linkFlags = lib.optionalString (frida.dev-kit != null) "-L${frida.dev-kit}/lib -lfrida-core";

    mkTags = tags: ["-tags=${lib.concatStringsSep "," tags}"];
  in {
    options = {
      commonArgs = lib.mkOption {
        type = lib.types.attrs;
        default = {
          buildInputs =
            [pkgs-2411.libusb1]
            ++ lib.optionals pkgs-2411.stdenv.hostPlatform.isDarwin (
              with pkgs-2411.darwin.apple_sdk.frameworks; [
                AppKit
                CoreFoundation
                Foundation
                IOKit
                Security
              ]
            )
            ++ lib.optionals (frida.dev-kit != null) [frida.dev-kit];

          env.CGO_ENABLED = 1;

          nativeBuildInputs = with config.toolchain; [
            clang
            bintools
          ];

          CGO_CFLAGS = compileFlags;
          CGO_LDFLAGS = linkFlags;
          GOFLAGS = mkTags [
            (lib.optionalString (frida.dev-kit != null) "frida")
          ];
        };
      };
    };
  };
}
