{
  buildPythonApplication,
  callPackage,
  lib,
  setuptools,
  writeText,
}:
let
  pywayfire = (callPackage ./pywayfire.nix {});
  rounded_corner_shader = writeText "rounded-corners" (builtins.readFile ./rounded-corners);
in
buildPythonApplication {
  pname = "wfire-round-corners";
  version = "1.0";
	src = ./scripts;
  dependencies = [
    pywayfire
    rounded_corner_shader
  ];
  installPhase = ''install -Dm755 main.py $out/bin/wayfire-round-corners'';
  preFixup = ''
    makeWrapperArgs+=(
      --set ROUNDED_CORNER_SHADER "${rounded_corner_shader}"
      --prefix PATH : ${lib.makeBinPath [ pywayfire ]}
    )
  '';

  pyproject = true;
  build-system = [
    setuptools
  ];
}