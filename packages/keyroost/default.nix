{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libxkbcommon,
  stdenv,
  wayland,
  nix-update-script,
  pkgs
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "keyroost";
  version = "0.7.6";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "framefilter";
    repo = "keyroost";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Nn4jokHlKS8GklJ/0t4AhY9vKigdZ0XCwwjnNVsM3vU=";
  };

  cargoHash = "sha256-Qk4yP2yC/TXavIwgfmc+UPc2MTHXzb3hvxDXCacMnws=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
    pkgs.pcsclite
  ]
  ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vendor Neutral, Rust-Based Management UI and CLI for U2F/FIDO2 and other hardware security keys";
    homepage = "https://github.com/framefilter/keyroost";
    changelog = "https://github.com/framefilter/keyroost/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "keyroost";
  };
})
