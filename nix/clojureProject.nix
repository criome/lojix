# Definition of the `clojureProjects.${name}` submodule
{ name, self, config, lib, pkgs, ... }:
let
  inherit (config.outputs) finalPackages finalOverlay;

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

  packageSubmodule = with types; submodule {
    options = {
      root = mkOption {
        type = path;
        description = "Path to clojure project root";
      };
    };
  };

in
{

  options = {
    basePackages = mkOption {
      type = types.attrsOf raw;
      description = '' '';
      example = "pkgs.haskell.packages.ghc924";
      default = pkgs.haskellPackages;
      defaultText = lib.literalExpression "pkgs.haskellPackages";
    };

    source-overrides = mkOption {
      type = types.attrsOf (types.oneOf [ types.path types.str ]);
      description = ''
        Source overrides for Clojure packages
      '';
      default = { };
    };

    overrides = mkOption {
      type = import ./haskell-overlay-type.nix { inherit lib; };
      description = ''
        Clojure package overrides for this project
      '';
      default = self: super: { };
      defaultText = lib.literalExpression "self: super: { }";
    };

    packages = mkOption {
      type = types.lazyAttrsOf packageSubmodule;
      description = ''
        Attrset of local packages in the project repository.
      '';
      default = { };
    };

    devShell = mkOption {
      type = devShellSubmodule;
      description = ''
        Development shell configuration
      '';
      default = { };
    };

    outputs = mkOption {
      type = outputsSubmodule;
      internal = true;
      description = ''
        The flake outputs generated for this project.
        This is an internal option, not meant to be set by the user.
      '';
    };
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
