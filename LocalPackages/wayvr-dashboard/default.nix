{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  desktop-file-utils,
  wrapGAppsHook3,
  makeBinaryWrapper,
  pkg-config,
  openssl,
  dbus,
  glib,
  glib-networking,
  libayatana-appindicator,
  callPackage,
  webkitgtk_4_1,
  alsa-lib,
  fontconfig,
  libGL,
  libuuid,
  libX11,
  libXext,
  libXrandr,
  libxkbcommon,
  openvr,
  openxr-loader,
  pipewire,
  pulseaudio,
  wayland,
  vulkan-loader,
  shaderc,
  wlx-overlay-s,
  #wayvr-frontend,
}:
let
  wayvr-frontend = callPackage ./wayvr-frontend.nix {};
in
rustPlatform.buildRustPackage rec {
  pname = "wayvr-dashboard";
  version = "master";

  src = fetchFromGitHub {
    owner = "olekolek1000";
    repo = "wayvr-dashboard";
    rev = version;
    hash = "sha256-vs4lk0B/D51WsHWOgqpTcPHf8WFaRJCkJyHZImDsdqk=";
  };

  sourceRoot = "${src.name}/src-tauri";
  useFetchCargoVendor = true;

  cargoHash = "sha256-/Lik6Hy80h5BL4rquVa3J9Fzqg2cOZKsRsLFzTgMle4=";

  postPatch =
    /*let
      cinny' =
        assert lib.assertMsg (
          cinny.version == version
        ) "cinny.version (${cinny.version}) != cinny-desktop.version (${version})";
        cinny.override {
          conf = {
            hashRouter.enabled = true;
          };
        };
    in*/
    ''
      substituteInPlace tauri.conf.json \
        --replace-warn '"frontendDist": "../dist"' '"frontendDist": "${wayvr-frontend}"'
      substituteInPlace tauri.conf.json \
        --replace-warn '"npm run build"' '""'
    '';

  /*postInstall =
	lib.optionalString stdenv.hostPlatform.isLinux ''
      desktop-file-edit \
        --set-comment "Yet another matrix client for desktop" \
        --set-key="Categories" --set-value="Network;InstantMessaging;" \
        $out/share/applications/cinny.desktop
    '';
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram "$out/bin/cinny" \
      --inherit-argv0 \
      --set-default WEBKIT_DISABLE_DMABUF_RENDERER "1"
  '';*/

  nativeBuildInputs = [
    wrapGAppsHook3
    pkg-config
    cargo-tauri.hook
    desktop-file-utils
	wlx-overlay-s
    makeBinaryWrapper
  ];

  buildInputs =
    [
      openssl
      dbus
      glib
      alsa-lib
      fontconfig
      libxkbcommon
      openvr
      openxr-loader
      pipewire
      libX11
      libXext
      libXrandr
	  libGL
      glib-networking
      webkitgtk_4_1
    ];
    #env.SHADERC_LIB_DIR = "${lib.getLib shaderc}/lib";

  /*meta = {
    description = "A dashboard for VR";
    homepage = "https://github.com/cinnyapp/cinny-desktop";
    maintainers = with lib.maintainers; [
    ];
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "wayvr-dashboard";
  };*/
}