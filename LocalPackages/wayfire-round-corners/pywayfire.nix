# toolz.nix
{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "wayfire";
  version = "3.2";

  src = fetchPypi {
    inherit pname version;
    hash = lib.fakeHash;
  };

  # do not run tests
  doCheck = false;

  # specific to buildPythonPackage, see its reference
  pyproject = true;
}