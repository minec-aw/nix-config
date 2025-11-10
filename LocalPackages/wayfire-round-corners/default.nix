{
	python3Packages,
  callPackage
}:
python3Packages.buildPythonApplication {
	pname = "wayfire-round-corners";
  version = "1.0";
	src = ./scripts;

  propagatedBuildInputs = [
    (callPackage ./pywayfire.nix {})
  ];
}