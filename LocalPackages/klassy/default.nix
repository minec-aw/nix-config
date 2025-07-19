{ lib
, stdenv
, fetchFromGitHub
, cmake
, extra-cmake-modules
, libsForQt5
, kdePackages
, qt6
}:

stdenv.mkDerivation rec {
  pname = "klassy";
  version = "6.1.breeze6.0.3";

  src = fetchFromGitHub {
    owner = "paulmcauley";
    repo = "klassy";
    rev = version;
    sha256 = "sha256-D8vjc8LT+pn6Qzn9cSRL/TihrLZN4Y+M3YiNLPrrREc=";
  };

  buildInputs = [
    kdePackages.frameworkintegration
    kdePackages.kcmutils
    kdePackages.kdecoration
    kdePackages.kirigami
    kdePackages.kguiaddons
    kdePackages.kcolorscheme
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.kiconthemes
    kdePackages.kwidgetsaddons
    kdePackages.kwayland
    kdePackages.kwindowsystem
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtdeclarative
  ];

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_TESTING=OFF"
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
    "-DBUILD_QT5=OFF"

  ];

  meta = {
    description = "A highly customizable binary Window Decoration and Application Style plugin for recent versions of the KDE Plasma desktop";
    homepage = "https://github.com/paulmcauley/klassy";
    changelog = "https://github.com/paulmcauley/klassy/releases/tag/${version}";
    license = with lib.licenses; [ bsd3 cc0 fdl12Plus gpl2Only gpl2Plus gpl3Only mit ];
    maintainers = with lib.maintainers; [ taj-ny ];
  };
}