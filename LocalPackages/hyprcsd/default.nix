{
  lib,
  mkHyprlandPlugin,
  fetchFromGitHub,
  nix-update-script,
}:

mkHyprlandPlugin {
  pluginName = "csd-titlebar-move";
  version = "0-unstable-2025-10-23";

  src = fetchFromGitHub {
    owner = "khalid151";
    repo = "csd-titlebar-move";
    rev = "bd8ac086009245396d9172c5acd0e43cd1cfc616";
    hash = "sha256-ZT+1doIIPyyo/qr0qsofixY9tZpNFP4N6P4Qjr99j0Y=";
  };

  dontUseCmakeConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mv csd-titlebar-move.so $out/lib/libcsd-titlebar-move.so

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Plugin to make your Hyprland cursor more realistic";
    homepage = "https://github.com/VirtCode/hypr-dynamic-cursors";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ donovanglover ];
    platforms = lib.platforms.linux;
  };
}