{ name, lib, pkgs, ... }:
let
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
        default = hp: { };
        defaultText = ''
          Build tools useful for Haskell development are included by default.
        '';
      };
      hlsCheck = mkOption {
        default = { };
        type = hlsCheckSubmodule;
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

  config = {
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
