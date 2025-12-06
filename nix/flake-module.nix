top: {
  perSystem = {config, ...}: {
    packages.ipsw = config.build.buildGoModule (finalAttrs:
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

        postInstall = ''
          mkdir -p "$out/share/man/man1"
          "$out/bin/ipsw" man "$out/share/man/man1"
        '';

        enableParallelBuilding = true;

        hardeningDisable = ["all"];
        NIX_ENFORCE_NO_NATIVE = 0;

        # TODO: fine-grained disabling of tests which require network or hardware
        doCheck = false;
      });
  };
}
