{ inputs, lib, ... }:
{
  systems = lib.systems.flakeExposed;

  imports = [
    inputs.nixpkgs.flakeModules.default
    inputs.clj-nix.flakeModules.default
    ./packagesModule.nix
    ./projectModule.nix
  ];

  perSystem = ./perSystem.nix;

  flake = {
    flakeModules = {
      default = ./packagesModule.nix;
      project = ./projectModule.nix;
    };
  };
}
