# Definition of the `clojureProjects.${name}` submodule
{ name, self', config, lib, pkgs, options, inputs', ... }:
let
  inherit (lib) types mapAttrsToList mkOption;

  devshellOptionsModule = {
    imports = [ inputs'.devshell.flakeModules.devshell ];
  };

  projectSubmodule = types.submoduleWith {
    specialArgs = { inherit pkgs self'; };
    modules = [ ./projectSubmodule.nix devshellOptionsModule ];
  };

  mkProjectOverlays = name: value:
    value.outputs.finalOverlay;

  projectOverlays = mapAttrsToList mkProjectOverlays config.clojureProjects;

  # Like mapAttrs, but merges the values (also attrsets) of the resulting attrset.
  mergeMapAttrs = f: attrs: lib.mkMerge (lib.mapAttrsToList f attrs);

in
{
  options = {
    clojureProjects = mkOption {
      description = "Clojure projects";
      type = types.attrsOf projectSubmodule;
      default = { };
    };
  };

  config = {
    clojurePackages = {
      overlays = projectOverlays;
    };

    packages = mergeMapAttrs
      (name: project:
        let
          mapKeys = f: attrs: lib.mapAttrs' (n: v: { name = f n; value = v; }) attrs;
          # Prefix package names with the project name (unless
          # project is named `default`)
          dropDefaultPrefix = packageName:
            if name == "default"
            then packageName
            else "${name}-${packageName}";
        in
        mapKeys dropDefaultPrefix project.outputs.localPackages)
      config.clojureProjects;

    devShells =
      mergeMapAttrs
        (name: project:
          lib.optionalAttrs project.enableDevshell {
            "${name}" = project.outputs.devshell;
          })
        config.clojureProjects;
  };
}
