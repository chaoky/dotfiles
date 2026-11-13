{
  perSystem = { pkgs, ... }: {
    packages.smokeapi = pkgs.callPackage
      ({ lib
       , stdenvNoCC
       , fetchurl
       , unzip
       ,
       }:

        stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "smokeapi";
          version = "4.1.3";

          src = fetchurl {
            url = "https://github.com/acidicoala/SmokeAPI/releases/download/v${finalAttrs.version}/SmokeAPI-v${finalAttrs.version}.zip";
            hash = "sha256-ikQ7W0xDSkkEsnLqTZOtfhPiEmJsDklGYXbLgowdKjs=";
          };

          nativeBuildInputs = [ unzip ];
          # The zip is flat (no top-level directory).
          sourceRoot = ".";

          dontBuild = true;
          # Prebuilt binaries meant to be copied into game directories; leave them untouched.
          dontStrip = true;
          dontPatchELF = true;

          installPhase = ''
            runHook preInstall
            install -Dm644 -t $out/share/smokeapi \
              smoke_api32.dll smoke_api64.dll \
              libsmoke_api32.so libsmoke_api64.so \
              README.txt SmokeAPI.config.json
            runHook postInstall
          '';

          meta = {
            description = "Steam DLC unlocker (open-source CreamAPI replacement); files to copy into a game directory";
            homepage = "https://github.com/acidicoala/SmokeAPI";
            license = lib.licenses.unlicense;
            sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
            platforms = [ "x86_64-linux" ];
          };
        }))
      { };
  };
}
