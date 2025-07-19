{ lib
, stdenv
, fetchFromGitHub
, cmake
, kdePackages
}:

stdenv.mkDerivation rec {
	pname = "lightly-boehs-qt6";
	version = "v0.4.2";

	src = fetchFromGitHub {
		owner = "boehs";
		repo = "Lightly";
		rev = "00ca23447844114d41bfc0d37cf8823202c082e8";
		sha256 = "sha256-NpgOcN9sDqgQMjqcfx92bfKohxaJpnwMgxb9MCu9uJM=";
	};

	buildInputs = with kdePackages; [
		kcmutils
		kconfig
		kdecoration
		kirigami
		kguiaddons
		kcolorscheme
		kcoreaddons
		ki18n
		kiconthemes
		kwindowsystem
	];

	extraCmakeFlags = [ "-DBUILD_TESTING=OFF" ];

	nativeBuildInputs = [
		cmake
		kdePackages.qttools
		kdePackages.extra-cmake-modules
		kdePackages.wrapQtAppsHook
	];
	patches = [ ./missing.patch ];

	meta = with lib; {
		description = "A fork of the Lightly breeze theme style that aims to be visually modern and minimalistic";
		mainProgram = "lightly-settings";
		homepage = "https://github.com/boehs/Lightly";
		license = licenses.gpl2Plus;
		maintainers = [ maintainers.hikari ];
		platforms = platforms.all;
	};
}