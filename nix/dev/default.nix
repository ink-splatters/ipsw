{inputs, ...}: {
  imports = [
    inputs.git-hooks.flakeModule
    ../common
    ./formatter.nix
    ./pre-commit.nix
    ./shell.nix
  ];
}
