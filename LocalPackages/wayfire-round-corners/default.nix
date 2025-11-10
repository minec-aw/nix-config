{
	python3Packages,
  callPackage,
  setuptools
}:
python3Packages.buildPythonApplication {
	pname = "wayfire-round-corners";
  version = "1.0";
	src = ./scripts;

  propagatedBuildInputs = [
    (callPackage ./pywayfire.nix {})
  ];
  pyproject = true;
  build-system = [
    setuptools
  ];
}