{
  fetchFromGitHub,
  lib,
  rustPlatform,
  opencv,
  nix-update-script,
  clang,
  pkg-config,
 }:

rustPlatform.buildRustPackage rec {
  pname = "mediatoascii-cli";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "spoorn";
    repo = "media-to-ascii";
    tag = version;
    hash = "sha256-4MfyEd07q3J+hAqgwG2QndN+I3JxxGcqs2cMyHWAOYY=";
  };

  cargoHash = "sha256-C5XyHODgipO8oMY84RTnfH/ylDnte/W2wa65fqkgWFU=";

  nativeBuildInputs = [
    pkg-config
    clang
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    opencv
  ];

  buildAndTestSubdir = "mediatoascii-cli";

  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI and utilities for converting media files (images/videos) to ascii outputs (output media file or print to console).";
    homepage = "https://crates.io/crates/mediatoascii";
    license = lib.licenses.mit;
    mainProgram = "mediatoascii-cli";
    # maintainers = with lib.maintainers; [
    #   chaoky
    # ];
  };
}
