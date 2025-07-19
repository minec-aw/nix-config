{ stdenv
, fetchFromGitHub
, cmake
, kdePackages
, libepoxy
, libxcb
, lib
}:

stdenv.mkDerivation rec {
  pname = "kde-rounded-corners";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "matinlotfali";
    repo = "KDE-Rounded-Corners";
    rev = "v${version}";
    hash = "sha256-8QkuIuHC0/fMxh8K3/I8GNhNPX+tw7kUMiU2oK12c0U=";
  };

  #postConfigure = ''
  #  substituteInPlace cmake_install.cmake \
  #    --replace "${kdelibs4support}" "$out"
  #'';

  nativeBuildInputs = [ cmake kdePackages.extra-cmake-modules kdePackages.wrapQtAppsHook ];
  buildInputs = [ kdePackages.kwin libepoxy libxcb kdePackages.kconfigwidgets kdePackages.kcmutils ];

  meta = with lib; {
    description = "Rounds the corners of your windows";
    homepage = "https://github.com/matinlotfali/KDE-Rounded-Corners";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}