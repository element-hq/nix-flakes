{ lib, pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [
    # The rust toolchain and related tools.
    # This will install the "default" profile of rust components.
    # https://rust-lang.github.io/rustup/concepts/profiles.html
    #(rust-bin.nightly."2025-07-25".default.override {
    (rust-bin.stable."1.85.0".default.override {
      # Additionally install the "rust-src" extension to allow diving into the
      # Rust source code in an IDE (rust-analyzer will also make use of it).
      extensions = [ "rust-src" ];
    })
    # The rust-analyzer language server implementation.
    rust-analyzer
    openssl

    # GCC includes a linker; needed for building `ruff`
    #gcc
    # Needed for building `ruff`
    #gnumake
    #libiconvReal
  ];

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
    #export LD_LIBRARY_PATH=$DEVENV_ROOT/.devenv/profile/lib
  '';
}
