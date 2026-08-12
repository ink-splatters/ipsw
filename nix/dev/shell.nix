{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) pre-commit commonArgs;
    GOFLAGS = "-tags=${builtins.concatStringsSep "," commonArgs.tags}";
  in {
    devShells.default =
      pkgs.mkShell.override {inherit (config) stdenv;}
      (builtins.removeAttrs commonArgs ["tags"]
        // {
          packages = pre-commit.settings.enabledPackages;

          shellHook = ''
            ${pre-commit.installationScript}
          '';

          env =
            commonArgs.env
            // {
              inherit GOFLAGS;
            };
        });
  };
}
