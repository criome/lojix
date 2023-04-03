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
    perSystem = mkPerSystemOption ({ config, system, pkgs, ... }@perSystemArgs:
      let
        clojurePackagesOverlay = self: super:
          let
            inherit (super.lib) makeScope makeOverridable dontRecurseIntoAttrs;
            inherit (super) newScope;
            inherit (config.clojurePackages) makeClojurePackages;

            clojurePackages = makeScope newScope (self: makeClojurePackages { });

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

        clojurePackagesSubmodule = types.submodule {
          options = {
            basePackages = mkOption {
              description = "Clojure packages";
              type = overlayType;
              example = "prev: final: { }";
              default = { };
            };

            makeClojurePackages = mkOption {
              type = makeClojurePackagesType;
              internal = true;
              description = "Returns `clojurePackages` from arguments";
              default = args:
                let
                  finalArgs = args // {
                    inherit lib pkgs;
                    cljNixOverlay = inputs.clj-nix.overlays.default;
                    overlays = (args.overlays or [ ])
                      ++ config.clojurePackages.overlays
                      ++ config.clojurePackages.projectOverlays;
                  };
                in
                import ./makePackages.nix finalArgs;
            };

            overlays = mkOption {
              description = "Clojure packages";
              type = types.listOf overlayType;
              example = "[ (prev: final: { }) ]";
              default = [ ];
            };

            projectOverlays = mkOption {
              description = "Clojure project overlays";
              type = types.listOf overlayType;
              example = "prev: final: { }";
              default = [ ];
            };
          };
        };

      in
      {
        options = {
          clojurePackages = mkOption {
            type = clojurePackagesSubmodule;
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
