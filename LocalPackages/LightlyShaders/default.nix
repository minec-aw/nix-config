{ lib
, stdenv
, fetchFromGitHub
, cmake
, kdePackages
}:

stdenv.mkDerivation rec {
	pname = "LightlyShaders";
	version = "v3.0.0";

	src = fetchFromGitHub {
		owner = "a-parhom";
		repo = "LightlyShaders";
		rev = "a380ae644caa874d79626bccc5674c7e653b99fe";
		sha256 = "sha256-QiB6nhPz/eckKP7+bbCARGiWxMjLqTp0wYaT1GggesU=";
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
		kwidgetsaddons
		kwin
		knotifications
		kservice
		kio
		kglobalaccel
		drkonqi
		kconfigwidgets
		kguiaddons
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
		mainProgram = "lightlyshaders";
		homepage = "https://github.com/a-parhom/LightlyShaders";
		license = licenses.gpl2Plus;
		maintainers = [ maintainers.hikari ];
		platforms = platforms.all;
	};
}