{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  cmake,
  imagemagick,
  libzip,
}:

stdenv.mkDerivation {
  pname = "ktools";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "dstmodders";
    repo = "ktools";
    rev = "master";
    hash = "sha256-ab1tla3ItPZ4bsXIZNkULV1rzKLQhfATVqLYsJlW1U0=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    imagemagick.dev
    libzip.dev
  ];
  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-platform (but Unix oriented) tools for modding Klei Entertainment's game Don't Starve.";
    homepage = "https://github.com/nsimplex/ktools";
    license = lib.licenses.gpl2;
    mainProgram = "krane";
  };
}
