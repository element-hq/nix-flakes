# ci.project-url: https://github.com/erikjohnston/matrix-hyper-federation-client
# ci.test-command: cargo build
{ pkgs, ... }:

{
  # Configure packages to install.
  # Search for package names at https://search.nixos.org/packages?channel=unstable
  packages = with pkgs; [
    # The rust toolchain and related tools.
    (rust-bin.stable."1.66.0".default.override {
      extensions = [ "rust-src" ];
    })
    
    # For enabling faster Rust compile times. See the `env` option below.
    clang
    mold
  ];

  # Set environment variables for the shell.
  env = {
    # Set the value of RUSTFLAGS. This overrides the `rustflags` setting in .cargo/config.toml.
    #
    # * -Clinker=clang -Clink-arg=-fuse-ld=lld
    #
    #     Use lld to link instead. Speeds up compile time.
    #
    # TODO: The lld flags may be Linux-only?
    "RUSTFLAGS" = "-Clinker=clang -Clink-arg=-fuse-ld=${pkgs.mold}/bin/mold";
  };
}