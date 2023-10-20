{ pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [
    # A rust compiler is needed in order to build native node modules.
    rust-bin.stable."1.71.1".default

    # For building seshat.
    gcc
    glib
    libsecret
    pkg-config
    sqlcipher

    yarn
  ];

  # Install JS dev tools (nodejs, npm, ...).
  languages.javascript.enable = true;
  #languages.c.enable = true;
}