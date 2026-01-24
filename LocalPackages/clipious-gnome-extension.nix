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
    hash = "sha256-Nq49kM6LcH7tp3AiaiE0M7wbHn16LSMhOHEQq4VFEuo=";
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
    substituteInPlace lib/misc/db.js \
      --replace-fail "gda = (await import('gi://Gda')).default" "imports.gi.GIRepository.Repository.prepend_search_path('${libgda6}/lib/girepository-1.0'); gda = (await import('gi://Gda')).default"
    substituteInPlace lib/common/sound.js \
      --replace-fail "const gsound = (await import('gi://GSound')).default" "imports.gi.GIRepository.Repository.prepend_search_path('${gsound}/lib/girepository-1.0'); const gsound = (await import('gi://GSound')).default"
    substituteInPlace lib/preferences/general/feedbackSettings.js \
      --replace-fail "const GSound = (await import('gi://GSound')).default" "imports.gi.GIRepository.Repository.prepend_search_path('${gsound}/lib/girepository-1.0'); const GSound = (await import('gi://GSound')).default"
    substituteInPlace lib/preferences/dependencies/dependencies.js \
      --replace-fail "await import('gi://GSound')" "imports.gi.GIRepository.Repository.prepend_search_path('${gsound}/lib/girepository-1.0'); const GSound = (await import('gi://GSound')).default" \
      --replace-fail "const Gda = (await import('gi://Gda')).default" "imports.gi.GIRepository.Repository.prepend_search_path('${libgda6}/lib/girepository-1.0'); const Gda = (await import('gi://Gda')).default"
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