# shell for developer mode (`nix develop`)
# recommended: automatic activation via nix-direnv (https://github.com/nix-community/nix-direnv)
# ```sh
# direnv allow .
# ```
{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) pre-commit commonArgs;
    GOFLAGS = let
      inherit (commonArgs.env) GOFLAGS;
    in
      builtins.toString GOFLAGS;
  in {
    devShells.default = pkgs.mkShell.override {inherit (config) stdenv;} (builtins.removeAttrs commonArgs ["GOFLAGS"]
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
