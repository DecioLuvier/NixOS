{ pkgs, python }:

let
  py = pkgs.python3Packages;
in

py.buildPythonPackage rec {
  pname = "bnn";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "1adrianb";
    repo = "binary-networks-pytorch";
    rev = "51bdeee";
    hash = "sha256-HL4O6OfVOSlbnXBXADioEVqV1QF5fgLJQDMZgCIh9/w=";
  };

  pyproject = true;

  build-system = with py; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with py; [
    torch
    torchvision
    easydict
  ];

  pythonImportsCheck = [ "bnn" ];
}