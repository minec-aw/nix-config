{
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel
}:

buildPythonPackage rec {
  pname = "wayfire";
  version = "3.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3Y4s/A05pEQu2v4VV77dLbBCEEAL+W0JwlwaoFH1Mgc=";
  };

  # do not run tests
  doCheck = false;

  # specific to buildPythonPackage, see its reference
  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];
}