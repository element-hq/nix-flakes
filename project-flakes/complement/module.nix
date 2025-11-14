{ lib, pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [];

  # Install Golang.
  languages.go.enable = true;
}
