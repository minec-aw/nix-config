{
  stdenv,
  lib,
  fetchFromGitHub,
  unstableGitUpdater,
  meson,
  ninja,
  pkg-config,
  wayfire,
  libinput,
  libxkbcommon,
  libGL,
  xcbutilwm,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixdecor";
  version = "0-unstable-2024-08-17";

  src = fetchFromGitHub {
    owner = "soreau";
    repo = "pixdecor";
    rev = "cc07c3461c6f4f04d2f1ec7ba0aef9e064b3131a";
    hash = lib.fakeHash;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  dontWrapGApps = true;

  buildInputs = [
    libGL
    libinput
    libxkbcommon
    nlohmann_json
    wayfire
    xcbutilwm
  ];

  postPatch = ''
    substituteInPlace metadata/meson.build \
      --replace "wayfire.get_variable( pkgconfig: 'metadatadir' )" "join_paths(get_option('prefix'), 'share/wayfire/metadata')"
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://github.com/soreau/pixdecor";
    description = "A highly configurable decorator plugin for wayfire,";
    longDescription = "pixdecor features antialiased rounded corners with shadows and optional animated effects.";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ _0x5a4 ];
    inherit (wayfire.meta) platforms;
  };
})