{
	lib,
	stdenv,
	hyprcursor,
	fetchFromGitHub,
}:
stdenv.mkDerivation {
	name = "macos-hyprcursor";
	src = fetchFromGitHub { 
		owner = "driedpampas"; 
		repo = "macOS-hyprcursor"; 
		rev = "v1"; 
		sha256 = "sha256-W7Uglem1qcneRFg/eR6D20p+ggkSFwh5QJYfq8OisLk="; 
	}; 
	#sourceRoot = "source/src/macOS (SVG)";

	nativeBuildInputs = [ hyprcursor ];

	installPhase = ''
		runHook preInstall

		mkdir -p $out/share/icons
		hyprcursor-util --create './src/macOS (SVG)' --output ./
		cp -r './theme_macOS (SVG)' $out/share/icons/macOS
		runHook postInstall
	'';

	meta = with lib; {
		description = "macOS cursor theme ported to hyprcusor";
		downloadPage = "https://github.com/driedpampas/macOS-hyprcursor";
		homepage = "https://github.com/driedpampas/macOS-hyprcursor";
		license = licenses.gpl3;
		maintainers = with maintainers; [ windowsxd ];
	};
}