{
  stdenv,
  lib,
  fetchFromGithub,
  meson,
  ninja,
  pkg-config,
  wayfire,
  eudev,
  libinput,
  libxkbcommon,
  librsvg,
  libGL,
  xcbutilwm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixdecor";
  version = "4893c7362d1b9b90b1208504579bc5b9618eceb5";

  src = fetchFromGithub {
    owner = "soreau";
    repo = "pixdecor";
    rev = "4893c7362d1b9b90b1208504579bc5b9618eceb5";
    hash = lib.fakeHash;
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace "wayfire.get_variable( pkgconfig: 'metadatadir' )" "join_paths(get_option('prefix'), 'share/wayfire/metadata')"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    wayfire
    eudev
    libinput
    libxkbcommon
    librsvg
    libGL
    xcbutilwm
  ];

  mesonFlags = [ "--sysconfdir=/etc" ];

  meta = {
    homepage = "https://gitlab.com/wayfireplugins/windecor";
    description = "Window decoration plugin for wayfire";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    inherit (wayfire.meta) platforms;
  };
})