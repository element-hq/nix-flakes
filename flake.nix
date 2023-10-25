{
  inputs = {
    # Aim for the latest versions of packages by default.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # A development environment manager built on Nix. See https://devenv.sh.
    devenv.url = "github:cachix/devenv/v0.6.3";
    # Output a development shell for x86_64/aarch64 Linux/Darwin (MacOS).
    systems.url = "github:nix-systems/default";
    # Rust toolchain.
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ devenv, nixpkgs, rust-overlay, systems, ... }:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      projectFlakesDirectory = ./project-flakes;
    in
    {
      # We need to build a developer shell for each system type.
      #
      # `forEachSystem` is a function that simply generates an attribute
      # set with each type of system as the keys, and the attribute set
      # defined below as the value.
      #
      # The result of the code below ends up looking like:
      # outputs = {
      #   devShells = {
      #     x86_64-linux = {
      #       synapse = devenv.lib.mkShell { ... }
      #     };
      #     aarch64-darwin = { ... };
      #     ...
      #   };
      # }
      devShells = forEachSystem (system:
        let
          # Instantiate nixpkgs and inject the various available Rust versions
          # as an overlay.
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
          # listToAttrs converts a list in the form:
          #   [ {name = a; value = 1}, {name = b; value = 2;} ]
          # into an attribute set:
          #   { a = 1; b = 2; }
          #
          # We use this to create an attribute set in the form:
          #  { synapse = devenv.lib.mkShell {...}; complement = devenv.lib.mkShell {...} }
          builtins.listToAttrs (map (projectName: {
            name = projectName;
            value = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [{
                imports = [
                  # Build the shell for this project with the module provided by
                  # the relevant file in $projectFlakesDirectory/$projectName.
                  "${projectFlakesDirectory}/${projectName}"
                  # ...and include the code from the common module.
                  ./common.nix
                ];
              }];
            };
          # Read the directory names in $projectFlakeDirectory into a list.
          # Note: using builtins.readDir is only allowed if `--impure` is
          # passed to the `nix develop` invocation.
          # devenv currently requires this, but eventually will not.
          # See https://github.com/cachix/devenv/pull/745
          #
          # When that happens, we can modify this to be a hardcoded list of
          # project names.
          }) (builtins.attrNames (builtins.readDir projectFlakesDirectory )))
      );
    };
}