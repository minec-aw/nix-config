{
  lib,
  buildNpmPackage,
  nodePackages,
  dart-sass,
  sassc,
  fetchFromGitHub,
  giflib,
  python3,
  pkg-config,
  pixman,
  cairo,
  pango,
  stdenv,
  olm,
  autoPatchelfHook
}:

buildNpmPackage rec {
  pname = "wayvr-frontend";
  version = "master";

  src = fetchFromGitHub {
    owner = "olekolek1000";
    repo = "wayvr-dashboard";
    rev = version;
    hash = "sha256-vs4lk0B/D51WsHWOgqpTcPHf8WFaRJCkJyHZImDsdqk=";
  };

  npmDepsHash = "sha256-W2X9g0LFIgkLbZBdr4OqodeN7U/h3nVfl3mKV9dsZTg=";
  NODE_OPTIONS = "--openssl-legacy-provider";
  # Fix error: no member named 'aligned_alloc' in the global namespace
  /*env.NIX_CFLAGS_COMPILE = lib.optionalString (
    stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinSdkVersion "11.0"
  ) "-D_LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION=1";*/

  nativeBuildInputs = [
    python3
    pkg-config
    dart-sass
    autoPatchelfHook
  ];
  preBuild = ''
    autoPatchelf node_modules/sass-embedded-linux-x64/dart-sass/src/dart
  '';
  dontAutoPatchelf = true;

  #dontNpmBuild = true;
  buildInputs = [
    sassc
    nodePackages.sass
    cairo
    pango
  ];

  installPhase = ''
    runHook preInstall
    cp -r dist $out

    runHook postInstall
  '';

  /*meta = {
    description = "";
    homepage = "https://cinny.in/";
    maintainers = with lib.maintainers; [ abbe ];
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
    #inherit (olm.meta) knownVulnerabilities;
  };*/
}