{ lib, pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [];

  # Install Python and manage a virtualenv with Poetry.
  languages.python.enable = true;
  languages.python.package = pkgs.python313;
  languages.python.poetry.enable = true;
  # Automatically activate the poetry virtualenv upon entering the shell.
  languages.python.poetry.activate.enable = true;
  # Install all extra Python dependencies; this is needed to run the unit
  # tests and utilitise all Synapse features.
  # Install the 'matrix-synapse' package from the local checkout.
  languages.python.poetry.install.installRootPackage = true;

  # Clear the LD_LIBRARY_PATH environment variable on shell init.
  #
  # By default, devenv will set LD_LIBRARY_PATH to point to .devenv/profile/lib. This causes
  # issues when we include `gcc` as a dependency to build C libraries, as the version of glibc
  # that the development environment's cc compiler uses may differ from that of the system.
  #
  # When LD_LIBRARY_PATH is set, system tools will attempt to use the development environment's
  # libraries. Which, when built against a different glibc version lead, to "version 'GLIBC_X.YY'
  # not found" errors.
  enterShell = ''
    #unset LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$DEVENV_ROOT/.devenv/profile/lib
  '';
}
