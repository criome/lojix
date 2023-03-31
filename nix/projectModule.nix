# Definition of the `clojureProjects.${name}` submodule
{ name, self, config, lib, pkgs, ... }:
let
  inherit (lib) types mapAttrsToList mkOption;
  inherit (config.outputs) finalPackages finalOverlay;

  projectSubmodule = types.submoduleWith {
    specialArgs = { inherit pkgs self; };
    modules = [ ./projectSubmodule.nix ];
  };

  mkProjectOverlays = name: value:
    value.outputs.finalOverlay;

  projectOverlays = mapAttrsToList mkProjectOverlays config.clojureProjects;


in
{

  options = {
    clojureProjects = mkOption {
      description = "Clojure projects";
      type = types.attrsOf projectSubmodule;
    };
  };


  config = {
    clojurePackages = {
      overlays = projectOverlays;
    };
  };
}
