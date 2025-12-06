{inputs, ...}: {
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    pre-commit = {
      check.enable = true;

      settings.hooks = {
        # markdown linting
        # TODO: enable and fix the issues
        # markdownlint.enable = true;

        # nix code linting
        deadnix.enable = true;
        nil.enable = true;
        alejandra.enable = true;
        statix.enable = true;

        # spell checking
        # TODO: enable, filtering out go files, as it catches some legitimate stuff like "udid".
        # alternative would be literal exclusion list if supported by the tool

        # typos.enable = true;
      };
    };

    apps.install-hooks = {
      type = "app";
      program = toString (pkgs.writeShellScript "install-hooks" ''
        ${config.pre-commit.installationScript}
        echo "Pre-commit hooks installed!"
      '');
      meta.description = "install pre-commit hooks";
    };
  };
}
