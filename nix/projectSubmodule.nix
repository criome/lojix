{ self', name, config, lib, pkgs, ... }:
let
  inherit (lib) types mkOption;
  inherit (types) functionTo;
  inherit (config.outputs) finalPackages;

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

  nativeBuildInputs = lib.attrValues
    (defaultBuildTools finalPackages // config.devShell.tools finalPackages);

  mkShellArgs = config.devShell.mkShellArgs // {
    nativeBuildInputs = (config.devShell.mkShellArgs.nativeBuildInputs or [ ])
      ++ nativeBuildInputs;
  };

  devShell = finalPackages.shellFor (mkShellArgs // {
    packages = p:
      map
        (name: p."${name}")
        (lib.attrNames config.packages);
  });

  packageSubmodule = with types; submodule
    ({ name, ... }:
      {
        options = {
          jdkRunner = mkOption {
            type = types.package;
            description = ''
              Derivation and clojure project version.
            '';
            default = pkgs.jdk;
          };

          version = mkOption {
            type = types.string;
            description = ''
              Derivation and clojure project version.
            '';
            default = "DEV";
          };

          main-ns = mkOption {
            type = types.string;
            description = ''
              Main clojure namespace. A `-main` function is expected here.
            '';
            default = "${name}-main";
          };

          java-opts = mkOption {
            description = ''
              Extra arguments for the Java command.
            '';
            default = [ ];
          };

          buildCommand = mkOption {
            description = ''
              Command to build the jar application. If not provided, a
              default builder is used:
            '';
            default = null;
          };

          projectSrc = mkOption {
            type = types.path;
            description = ''
              Project source code.
            '';
          };
        };
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

      cljLspCheck = mkOption {
        type = types.package;
        readOnly = true;
        description = ''
          The `cljLspCheck` derivation generated for this project.
        '';
      };
    };
  };

  cljLspCheckSubmodule = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        description = ''
          Whether to enable a flake check to verify that Clojure-lsp works.
        '';
        default = false;
      };

    };
  };

  devShellSubmodule = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        description = ''
          Whether to enable a development shell for the project.
        '';
        default = true;
      };

      tools = mkOption {
        type = functionTo (types.attrsOf (types.nullOr types.package));
        description = ''
          Build tools for developing the Haskell project.
        '';
        default = cljPkgs: { };
        defaultText = ''
          Build tools useful for Haskell development are included by default.
        '';
      };

      cljLspCheck = mkOption {
        default = { };
        type = cljLspCheckSubmodule;
        description = ''
          A [check](flake-parts.html#opt-perSystem.checks) to make sure that your IDE will work.
        '';
      };

      mkShellArgs = mkOption {
        type = types.attrsOf types.raw;
        description = ''
          Extra arguments to pass to `pkgs.mkShell`.
        '';
        default = { };
        example = ''
          {
            shellHook = \'\'
              # Re-generate .cabal files so HLS will work (per hie.yaml)
              ''${pkgs.findutils}/bin/find -name package.yaml -exec hpack {} \;
            \'\';
          };
        '';
      };
    };
  };

in
{
  options = {
    root = mkOption {
      type = types.path;
      description = ''
        Source root for this project
      '';
      default = if name == "default" then self'.outPath else null;
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
      default = import ./findProjectPaths.nix {
        inherit (config) root;
        inherit lib name;
      };

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
    outputs = {
      inherit devShell;

      finalOverlay = lib.composeManyExtensions [
        localPackagesOverlay
        config.overrides
      ];

      finalPackages = pkgs.clojurePackages;

      localPackages = lib.mapAttrs
        (name: _: finalPackages."${name}")
        config.packages;
    };
  };
}
