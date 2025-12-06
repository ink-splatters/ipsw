top: {
  perSystem = {config, ...}: {
    packages.ipsw = config.toolchain.buildGoModule (finalAttrs:
      config.commonArgs
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

        # TODO: fine-grained disabling of tests which require network or hardware
        doCheck = false;
      });
  };
}
