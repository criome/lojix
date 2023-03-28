{ inputs, lib, ... }:
let
  clojurePackages = ./clojurePackages.nix;
  clojureProject = ./clojureProject.nix;
  allModules = [ clojurePackages clojureProject ];

in
{
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  imports = ./flakeModule.nix
    ++ [ inputs.clj-nix.flakeModules.default ];

  perSystem = ./perSystem.nix;

  flake = {
    flakeModules = {
      default = ./flakeModule.nix;
      inherit clojurePackages clojureProject;
    };
  };
}
