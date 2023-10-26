# ci.project-url: https://github.com/vector-im/element-web
{ pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [
    yarn
  ];

  # Install JS dev tools (nodejs, npm, ...).
  languages.javascript.enable = true;
}