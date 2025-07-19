{ lib
, stdenv
, cmake
, kdePackages
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
	pname = "kwin-effects-forceblur";
	version = "v1.3.1";

	src = fetchFromGitHub {
		owner = "taj-ny";
		repo = "kwin-forceblur";
		rev = version;
		sha256 = "sha256-aJYijkwDA5IRy9Vtj4s+RtD1gamcoyrnlh2LXv+FgE8=";
	};

	nativeBuildInputs = [
		cmake
		kdePackages.extra-cmake-modules
		kdePackages.wrapQtAppsHook
	];

	buildInputs = [
		kdePackages.kwin
		kdePackages.qttools
	];

	meta = with lib; {
		description = "A fork of the KWin Blur effect for KDE Plasma 6 with the ability to blur any window on Wayland and X11";
		license = licenses.gpl3;
		homepage = "https://github.com/taj-ny/kwin-effects-forceblur";
	};
}