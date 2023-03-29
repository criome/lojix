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

  outputsSubmodule = types.submodule {
    options = {
      finalOverlay = mkOption {
        type = types.raw;
        readOnly = true;
        internal = true;
      };
      finalPackages = mkOption {
        # This must be raw because the Haskell package set also contains functions.
        type = types.attrsOf types.raw;
        readOnly = true;
        description = ''
          The final Haskell package set including local packages and any
          overrides, on top of `basePackages`.
        '';
      };
      localPackages = mkOption {
        type = types.attrsOf types.package;
        readOnly = true;
        description = ''
          The local Haskell packages in the project.

          This is a subset of `finalPackages` containing only local
          packages excluding everything else.
        '';
      };
      devShell = mkOption {
        type = types.package;
        readOnly = true;
        description = ''
          The development shell derivation generated for this project.
        '';
      };
      hlsCheck = mkOption {
        type = types.package;
        readOnly = true;
        description = ''
          The `hlsCheck` derivation generated for this project.
        '';
      };
    };
  };

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
    modules = [{
      options = {
        basePackages = mkOption {
          type = types.attrsOf raw;
          description = ''Base Clojure packages'';
          default = config.clojure.packages;
          defaultText = lib.literalExpression "config.clojure.packages";
        };

        source-overrides = mkOption {
          type = types.attrsOf (types.oneOf [ types.path types.str ]);
          description = ''
            Source overrides for Clojure packages
          '';
          default = { };
        };

        overrides = mkOption {
          type = import ./overlayType.nix lib;
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
    }];
  };


in
{

  options = {
    clojureProjects = mkOption {
      description = "Clojure projects";
      type = types.attrsOf projectSubmodule;
    };
  };


  config = {
    clojure = {
      overlays = projectOverlays;
    };

    outputs = {
      inherit devShell;

      finalOverlay = lib.composeManyExtensions [
        localPackagesOverlay
        (pkgs.clojure.lib.packageSourceOverrides config.source-overrides)
        config.overrides
      ];

      finalPackages = { };

      localPackages = lib.mapAttrs
        (name: _: finalPackages."${name}")
        config.packages;

    };
  };
}
