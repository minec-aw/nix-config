{
  lib,
  stdenv,
  fetchzip,
  glib,
  libgda6,
  gsound,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-shell-extension-copyous";
  version = "1.3.0";

  src = fetchzip {
    #https://github.com/boerdereinar/copyous/releases
    url = "https://github.com/boerdereinar/copyous/releases/download/v${finalAttrs.version}/copyous@boerdereinar.dev.zip";
    hash = lib.fakeHash;
    stripRoot = false;
  };

  nativeBuildInputs = [
    glib
  ];

  buildPhase = ''
    runHook preBuild
    glib-compile-schemas --strict schemas
    runHook postBuild
  '';

  preInstall = ''
    substituteInPlace extension.js \
      --replace-fail "import Gda from 'gi://Gda?version>=5.0'" "imports.gi.GIRepository.Repository.prepend_search_path('${libgda6}/lib/girepository-1.0'); const Gda = (await import('gi://Gda')).default" \
      --replace-fail "import GSound from 'gi://GSound'" "imports.gi.GIRepository.Repository.prepend_search_path('${gsound}/lib/girepository-1.0'); const GSound = (await import('gi://GSound')).default"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions
    cp -r -T . $out/share/gnome-shell/extensions/copyous@boerdereinar.dev
    runHook postInstall
  '';

  passthru = {
    extensionPortalSlug = "copyous";
    extensionUuid = "copyous@boerdereinar.dev";
  };

  meta = {
    description = "Next-gen Clipboard Manager for Gnome Shell";
    homepage = "https://github.com/boerdereinar/copyous";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ honnip ];
    platforms = lib.platforms.linux;
  };
})