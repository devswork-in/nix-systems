{ pkgs, lib, ... }:

let
  rich = pkgs.python3Packages.rich.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "Textualize";
      repo = "rich";
      rev = "refs/tags/v13.3.2";
      hash = "sha256-Mc2ZTpn2cPGXIBblwwukJGiD8etdVi8ag9Xb77gG62A=";
    };
  });

  requests = pkgs.python3Packages.requests.overrideAttrs(old: {
    src = pkgs.python3Packages.fetchPypi {
      pname = "requests";
      version = "2.28.2";
      hash = "sha256-mLGyeC48bEkEk4uEwOuTJyEGnf25E0MTvv98g8LfJL8=";
    };
  });

  typer = pkgs.python3Packages.typer.overrideAttrs(old: {
    src = pkgs.python3Packages.fetchPypi {
      pname = "typer";
      version = "0.7.0";
      hash = "sha256-/3l4RleKnyogG1NEKu3rVDMZRmhw++HHAeq2bddoEWU=";
    };
  });


  sgpt = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "sgpt";
    version = "0.0.1";
    format = "pyproject";

    disabled = pkgs.python3.pythonOlder "3.6";

    src = pkgs.fetchgit {
      url = "https://github.com/creator54/shell_gpt.git";
      #sha256 = lib.fakeSha256;
      sha256 = "sha256-VdTz8xDy7MDf697gaJojNoOZWSwCVK4vnwDCbNt83qU=";
    };

    propagatedBuildInputs = [
      rich
      requests
      typer
      pkgs.python3Packages.setuptools
    ];

    pythonImportsCheck = [ "sgpt" ];

    meta = with pkgs.lib; {
      homepage = "https://github.com/TheR1D/shell_gpt";
      description = "A command-line interface (CLI) productivity tool powered by OpenAI's GPT-3 models, will help you accomplish your tasks faster and more efficiently.";
      maintainers = with maintainers; [ creator54 ];
      license = licenses.mit;
    };
  };
in
{
  home.packages = [ sgpt ];
}
