{ inputs, self, config, lib, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    dontRecurseIntoAttrs
    mkOption
    types;
  inherit (types)
    functionTo
    raw;


in
{


  options = {
    perSystem = mkPerSystemOption ({ config, system, pkgs, ... }:
      let
        clojurePackagesOverlay = self: super:
          let
            inherit (super.lib) makeScope newScope makeOverridable dontRecurseIntoAttrs;
            inherit (config.clojurePackages) makeClojurePackages;

            clojurePackages = makeScope newScope makeClojurePackages;

          in
          { clojurePackages = dontRecurseIntoAttrs clojurePackages; };

        overlayType = import ./overlayType.nix lib;

        makeClojurePackagesType = types.mkOptionType {
          name = "makeClojurePackagesType";
          description = ''
            A function that returns `clojurePackages` from a set of arguments
          '';
          descriptionClass = "noun";
          check = lib.isFunction;
        };

        clojureSubmodule = types.submodule {
          options = {
            basePackages = mkOption {
              description = "Clojure packages";
              type = overlayType;
              example = "prev: final: { }";
              default = { };
            };

            makePackages = mkOption {
              type = makeClojurePackagesType;
              internal = true;
              description = "Returns `clojurePackages` from arguments";
              default = import ./makePackages.nix;
            };

            overlays = mkOption {
              description = "Clojure packages";
              type = types.listOf overlayType;
              example = "prev: final: { }";
              default = clojurePackagesBaseOverlay;
            };
          };
        };

        finalOverlay = lib.composeManyExtensions
          # Last element has priority, so `perSystem` overlays rule
          (topLevel.config.nixpkgs.overlays ++ config.nixpkgs.overlays);

        finalPackages = config.clojure.makePackages
          { inherit pkgs lib; overlays = [ finalOverlay ]; };

      in
      {
        options = {
          clojurePackages = mkOption {
            type = clojureSubmodule;
            description = "Clojure configuration";
            default = { };
          };
        };

        config = {
          nixpkgs.overlays = [ clojurePackagesOverlay ];
        };
      });
  };
}
