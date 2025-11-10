{
  buildPythonApplication,
  callPackage,
  lib,
  setuptools,
}:
let
  pywayfire = (callPackage ./pywayfire.nix {});
in
buildPythonApplication {
  pname = "wfire-round-corners";
  version = "1.0";
	src = ./scripts;
  dependencies = [
    pywayfire
  ];
  installPhase = ''install -Dm755 main.py $out/bin/wayfire-round-corners'';
  preFixup = ''
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ pywayfire ]})
  '';

  pyproject = true;
  build-system = [
    setuptools
  ];
}