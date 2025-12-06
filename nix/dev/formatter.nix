{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    formatter = pkgs.writeShellScriptBin "fmt-all" ''
      ${pkgs.alejandra}/bin/alejandra .

      # echo "Formatting Go files..."
      # ${config.build.toolchain.go}/bin/go fmt ./...
    '';
  };
}
