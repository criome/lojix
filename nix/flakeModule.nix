{ self, config, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
  inherit (types)
    functionTo
    raw;

  cljNixPackages = {
    inherit (pkgs)
      clj-builder
      deps-lock
      mk-deps-cache
      mkCljBin
      mkCljLib
      mkGraalBin
      customJdk
      mkBabashka
      bbTasksFromFile;
  };

  baseClojurePackages = cljNixPackages;

  clojureSubmodule = types.submodule {
    options = {
      runtime = mkOption {
        type = types.derivation;
        description = "Clojure runtime";
        default = pkgs.clojure;
        example = "pkgs.someCustomClojure";
        defaultText = lib.literalExpression "pkgs.clojure";
      };

      packages = mkOption {
        description = "Clojure packages";
        type = types.attrsOf raw;
        example = "pkgs.someCustomClojurePackages";
        default = baseClojurePackages;
      };

    };
  };
in
{
  options = {
    clojure = mkOption {
      type = clojureSubmodule;
      description = "Clojure configuration";
      default = { };
    };

    perSystem = mkPerSystemOption (import ./clojureProject.nix);
  };
}
