{
  perSystem = {pkgs, ...}: {
    formatter = pkgs.writeShellScriptBin "fmt-all" ''
      ${pkgs.alejandra}/bin/alejandra .

      # echo "Formatting Go files..."
      # ${pkgs.go_1_26}/bin/go fmt ./...
    '';
  };
}
