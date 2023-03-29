{ inputs, lib, ... }:
{
  systems = lib.systems.flakeExposed;

  imports = [
    ./flakeModule.nix
    inputs.clj-nix.flakeModules.default
  ];

  perSystem = ./perSystem.nix;

  flake = {
    flakeModules = {
      default = ./flakeModule.nix;
    };
  };
}
