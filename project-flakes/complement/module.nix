# ci.project-url: https://github.com/matrix-org/complement
# ci.test-command: go build ./tests/...
{ pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [
    # For performing Matrix olm/megolm crypto.
    olm
  ];

  # Install the latest version of the Go programming language.
  languages.go.enable = true;
}