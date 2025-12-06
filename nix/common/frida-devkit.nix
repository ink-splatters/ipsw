top @ {lib, ...}: {
  perSystem = {pkgs, ...}: let
    inherit (top.config) frida;
    inherit (pkgs) fetchurl stdenvNoCC;

    platformTag = stdenvNoCC.hostPlatform.system;

    sources = lib.attrByPath [platformTag] null frida.sources;
  in {
    # cannot use config.packages because it cannot contain null attrs,
    # which is the case for frida on unsupported platforms
    config.frida.dev-kit = lib.mkIf (sources != null) (stdenvNoCC.mkDerivation {
      pname = "frida-devkit";
      inherit (frida) version;

      src = fetchurl {
        inherit (sources) url hash;
      };

      sourceRoot = ".";

      dontBuild = true;
      dontConfigure = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/include $out/lib

        cp frida-core.h $out/include/
        cp libfrida-core.a $out/lib/

        mkdir -p $out/lib/pkgconfig
        cat > $out/lib/pkgconfig/frida-core.pc << EOF
        prefix=$out
        includedir=''${prefix}/include
        libdir=''${prefix}/lib

        Name: frida-core
        Description: Frida core library
        Version: ${frida.version}
        Cflags: -I''${includedir}
        Libs: -L''${libdir} -lfrida-core
        EOF

        runHook postInstall
      '';

      meta = with lib; {
        description = "Frida core devkit - pre-built library for building Frida bindings";
        homepage = "https://frida.re";
        license = licenses.lgpl3Plus;
        platforms = builtins.attrNames frida.sources;
      };
    });
  };
}
