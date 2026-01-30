{
  imports = [
    ./config.nix
    ./common
  ];

  perSystem = {config, ...}: let
    inherit (config) commonArgs;
    inherit (config.toolchain) buildGo126Module;

    commonArgsStripped = builtins.removeAttrs commonArgs ["CGO_CFLAGS" "CGO_LDFLAGS"];

    CGO_CFLAGS = builtins.toString [
      commonArgs.CGO_CFLAGS
      "-O3"
      "-mcpu=native"
      "-flto=thin"
    ];

    CGO_LDFLAGS = builtins.toString [
      commonArgs.CGO_LDFLAGS
      "-flto=thin"
      "-Wl,-dead_strip"
    ];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=${config.version}"
    ];
  in {
    packages.ipsw = buildGo126Module (commonArgsStripped
      // {
        pname = "ipsw";
        inherit (config) src version vendorHash;

        subPackages = ["./cmd/ipsw"];

        enableParallelBuilding = true;

        hardeningDisable = ["all"];
        NIX_ENFORCE_NO_NATIVE = 0;

        inherit CGO_CFLAGS CGO_LDFLAGS ldflags;

        # TODO: fine-grained disabling of tests which require network or hardware
        doCheck = false;
      });
  };
}
