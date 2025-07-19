{ 
	lib,
	fetchFromGitHub,
	python3,
	stdenv,
	python3Packages,
	kdePackages,
	symlinkJoin,
	cmake
}:

let
	pname = "kde-material-you-colors";
	version = "v1.9.3";
	source = fetchFromGitHub {
		owner = "luisbocanegra";
		repo = "kde-material-you-colors";
		rev = "v1.9.3";
		sha256 = "sha256-hew+aWbfWmqTsxsNx/0Ow0WZAVl0e6OyzDxcKm+nlzQ=";
	};
	backend = python3.pkgs.buildPythonPackage rec {
		inherit pname version;
		src = source;

		nativeBuildInputs = with python3Packages; [
			setuptools
		];
		propagatedBuildInputs = with python3Packages; [
			dbus-python
			numpy
			materialyoucolor
			material-color-utilities
			pywal
		];

		postPatch = ''
			substituteInPlace src/kde_material_you_colors/main.py \
			--replace "#!/usr/bin/python3" "#!${python3}/bin/python3" \
		'';

		format = "pyproject";
	};
	frontend = stdenv.mkDerivation rec {
		inherit pname version;
		src = source; #"${source}/src/plasmoid";
		#sourceRoot = "${src}/src/plasmoid";
		buildInputs = [
			backend
			kdePackages.libplasma
		];

		nativeBuildInputs = with kdePackages; [
			kpackage
			cmake
			kdePackages.wrapQtAppsHook
		];
		#dontWrapQtApps = true;
		dontBuild = true;
		postPatch = ''
			substituteInPlace src/plasmoid/package/contents/ui/FullRepresentation.qml \
			--replace "#!/usr/bin/python3" "#!${python3}/bin/python3" \
		'';
		# installPhase = ''
		# 	runHook preInstall

		# 	kpackagetool6 --install $src/package --packageroot $out/share/plasma/plasmoids

		# 	runHook postInstall
		# '';
	};
in
symlinkJoin rec {
	inherit pname version;
	name = pname;
	paths = [
		backend
		#frontend
	];
	meta = with lib; {
		description = "Automatic color scheme generator from your wallpaper for the Plasma Desktop powered by Material You";
		license = licenses.gpl2;
		maintainers = with maintainers; [ kasper ];
		inherit (src.meta) homepage;
		inherit (kdePackages.kwindowsystem.meta) platforms;
	};
}