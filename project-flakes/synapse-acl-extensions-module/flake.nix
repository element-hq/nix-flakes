# ci.project-url: https://github.com/element-hq/synapse-acl-extensions-module
{
  inputs = {
    utility.url = "path:///home/work/code/nix-flakes/utility";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Synapse uses Complement and Sytest as integration test suites. The
    # dependencies needed to run/add/modify tests for these suites is
    # necessary.
    complement.url = "path:///home/work/code/nix-flakes/project-flakes/complement";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      overlays = []
        ++ inputs.complement.overlays;
      module = (import ./module.nix);
    in {
      inherit overlays module;
    } // inputs.utility.mkDevShells {
      inherit nixpkgs overlays;
      modules = [
        module
        inputs.complement.module
      ];
    };
}
