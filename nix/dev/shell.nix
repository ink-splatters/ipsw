{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) pre-commit commonArgs;
    GOFLAGS = builtins.toString commonArgs.env.GOFLAGS;
  in {
    # note that this dev shell doesn't include optimization flags on purpose
    devShells.default =
      pkgs.mkShell.override {inherit (config) stdenv;}
      (commonArgs
        // {
          packages = pre-commit.settings.enabledPackages;

          shellHook = ''
            ${pre-commit.installationScript}
          '';

          env = {
            inherit GOFLAGS;
          };
        });
  };
}
