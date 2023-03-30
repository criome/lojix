# Definition of the `clojureProjects.${name}` submodule
{ name, self, config, lib, pkgs, ... }:
let
  inherit (lib) types;
  inherit (types) mkOption;
  inherit (config.outputs) finalPackages finalOverlay;

  projectKey = name;

  localPackagesOverlay = self: _:
    let
      mkClojurePackageFromPackageNameAndConfig = name: value:
        self.mkCljBin (value // { inherit name; });
    in
    lib.mapAttrs
      mkClojurePackageFromPackageNameAndConfig
      config.packages;

  defaultBuildTools = cljPkgs: with cljPkgs; {
    inherit
      clojure;
  };

  nativeBuildInputs = lib.attrValues (defaultBuildTools finalPackages // config.devShell.tools finalPackages);

  mkShellArgs = config.devShell.mkShellArgs // {
    nativeBuildInputs = (config.devShell.mkShellArgs.nativeBuildInputs or [ ]) ++ nativeBuildInputs;
  };

  devShell = finalPackages.shellFor (mkShellArgs // {
    packages = p:
      map
        (name: p."${name}")
        (lib.attrNames config.packages);
  });



  packageSubmodule = with types; submodule {
    options = {
      root = mkOption {
        type = path;
        description = "Path to clojure project root";
      };
    };
  };

  projectSubmodule = types.submoduleWith {
    specialArgs = { inherit pkgs self; };
    modules = [ ./projectSubmodule.nix ];
  };

  mkProjectOverlays = name: value:
    value.overrides;

  projectOverlays = builtins.concatmap
    (mapAttrsToList mkProjectOverlays config.clojureProjects);


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
