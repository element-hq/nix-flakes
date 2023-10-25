{
  inputs = {
    # A development environment manager built on Nix. See https://devenv.sh.
    devenv.url = "github:cachix/devenv/v0.6.3";
    # Output a development shell for x86_64/aarch64 Linux/Darwin (MacOS).
    systems.url = "github:nix-systems/default";
    # Rust toolchain.
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs@{ devenv, nixpkgs, rust-overlay, systems, ... }:
    let
      # The local directory where project-specific flakes are stored.
      projectFlakesDirectory = ./project-flakes;

      # `forEachSystem` is a function that simply generates an attribute
      # set with each type of system as the keys, and the attribute set
      # defined below as the value.
      #
      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      # Instantiate nixpkgs and inject the various available Rust versions
      # as an overlay.
      #
      # mkPkgs is a function that builds an instance of nixpkgs with the
      # given system.
      overlays = [ (import rust-overlay) ];
      mkPkgs = system:
        import nixpkgs {
          inherit system overlays;
        };
    in
    {
      # We want to build a developer shell for each system type.
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
        # listToAttrs converts a list like:
        #   [ {name = a; value = 1}, {name = b; value = 2;} ]
        # into an attribute set:
        #   { a = 1; b = 2; }
        #
        # We use this to create an attribute set like:
        #  { synapse = devenv.lib.mkShell {...}; complement = devenv.lib.mkShell {...} }
        builtins.listToAttrs (map (projectName: {
          name = projectName;
          value = devenv.lib.mkShell {
            inherit inputs;
            pkgs = mkPkgs system;
            modules = [{
              imports = [ "${projectFlakesDirectory}/${projectName}" ./common.nix ];
            }];
          };
        # Get the directory names in $projectFlakeDirectory as a list.
        #
        # Note: using builtins.readDir is only allowed if `--impure` is
        # passed to the `nix develop` invocation.
        # devenv currently requires this, but eventually will not.
        # See https://github.com/cachix/devenv/pull/745
        #
        # When that happens, we could modify this to be a hardcoded list of
        # project names, to avoid users needing to specify `--impure`.
        }) (builtins.attrNames (builtins.readDir projectFlakesDirectory )))
      );
      # Define a flake output `composeShell`, which is a function that takes
      # a list `projectNames`, and returns an attribute set of the default
      # systems to a devenv shell with given project modules + the "common"
      # module. This fits the expected value of the `devShells` flake output.
      #
      # This is useful for downstream flakes that want to combine multiple
      # project flakes together into one shell (i.e. Synapse developers may
      # also want the dependencies for the complement and sytest dev shells).
      #
      # For example:
      #
      #  outputs = {...}:
      #   devShells = composeShell ["synapse" "complement" "sytest"];
      composeShell = projectNames: forEachSystem (system:
        {
          default = devenv.lib.mkShell {
            inherit inputs;
            pkgs = mkPkgs system;
            modules = map (projectName: {
              imports = [
                "${projectFlakesDirectory}/${projectName}"
                ./common.nix
              ];
            }) projectNames;
          };
        }
      );
    };
}