# Definition of the `clojureProjects.${name}` submodule
{ name, self, config, lib, pkgs, ... }:
let
  inherit (config.outputs) finalPackages finalOverlay;

  packageSubmodule = with types; submodule {
    options = {
      root = mkOption {
        type = path;
        description = "Path to clojure project root";
      };
    };
  };

  projectKey = name;

  localPackagesOverlay = self: _:
    let
      mkClojurePackageFromPackageNameAndConfig = name: value:
        let
          root = { };
        in
        self.mkCljBin name root;
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
in
{
  projectSubmodule = types.submoduleWith {
    specialArgs = { inherit pkgs self; };
    modules = [ ./clojureProject.nix ];
  };

  config = {
    nixkpgs.overlays = [ ];

    outputs = {
      inherit devShell;

      finalOverlay = lib.composeManyExtensions [
        # The order here matters.
        #
        # User's overrides (cfg.overrides) is applied **last** so
        # as to give them maximum control over the final package
        # set used.
        localPackagesOverlay
        (pkgs.clojure.lib.packageSourceOverrides config.source-overrides)
        config.overrides
      ];

      finalPackages = config.basePackages.extend finalOverlay=;

      localPackages = lib.mapAttrs
        (name: _: finalPackages."${name}")
        config.packages;

    };
  };
}
