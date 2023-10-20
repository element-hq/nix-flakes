# devenv configuration that is common to all projects.
{ ... }:

{
  # Make use of the Starship command prompt when this development environment
  # is manually activated (via `nix develop --impure`).
  # See https://starship.rs/ for details on the prompt itself.
  starship.enable = true;
}