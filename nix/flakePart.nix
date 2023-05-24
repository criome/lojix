{ inputs, lib, ... }:
{
  systems = lib.systems.flakeExposed;

  imports = [
    inputs.nixpkgs.flakeModules.default
  ];

  perSystem = ./perSystem.nix;

  flake = {
    flakeModules = {
      default = ./packagesModule.nix;
      project = ./projectModule.nix;
    };
  };
}
