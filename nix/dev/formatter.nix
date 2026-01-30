{
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    formatter = pkgs.writeShellScriptBin "fmt-all" ''
      ${pkgs.alejandra}/bin/alejandra .

      # echo "Formatting Go files..."
      # ${config.toolchain.go_1_26}/bin/go fmt ./...
    '';
  };
}
