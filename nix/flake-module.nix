top @ {lib, ...}: {
  perSystem = {config, ...}: let
    inherit (config) commonArgs;
    inherit (commonArgs) CGO_CFLAGS;

    # commonArgs is an attrset, not a derivation, so overrideAttrs cannot be used.
    # we remove the attrs we want to override, then re-add them extended with compiler flags
    commonArgsStripped = builtins.removeAttrs commonArgs ["CGO_CFLAGS"];
    compileFlags = ["-mcpu=native"];
  in {
    packages.ipsw = config.toolchain.buildGoModule (finalAttrs: (commonArgsStripped
      // {
        pname = "ipsw";
        inherit (top.config) version vendorHash src;
        proxyVendor = true;

        ldflags = [
          "-s"
          "-w"
          "-X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=${finalAttrs.version}"
        ];

        subPackages = ["./cmd/ipsw"];

        enableParallelBuilding = true;

        hardeningDisable = ["all"];
        NIX_ENFORCE_NO_NATIVE = 0;

        CGO_CFLAGS = lib.concatStringsSep " " ([CGO_CFLAGS] ++ compileFlags);

        # TODO: fine-grained disabling of tests which require network or hardware
        doCheck = false;
      }));
  };
}
