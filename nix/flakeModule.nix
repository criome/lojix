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

  clojurePackagesOverlay = self: super:
    let
      inherit (super.lib) makeScope newScope makeOverridable dontRecurseIntoAttrs;
      inherit (config.clojurePackages) makeClojurePackages;

      clojurePackages = makeScope newScope makeClojurePackages;

    in
    { clojurePackages = dontRecurseIntoAttrs clojurePackages; };

  overlayType = import ./overlayType.nix lib;

  clojureSubmodule = types.submodule {
    options = {
      basePackages = mkOption {
        description = "Clojure packages";
        type = overlayType;
        example = "prev: final: { }";
        default = { };
      };

      makePackages = mkOption {
        type = mkPkgsFromArgsType;
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
in
{
  config = {
    nixpkgs.overlays = [ clojurePackagesOverlay ];
  };

  options = {
    clojure = mkOption {
      type = clojureSubmodule;
      description = "Clojure configuration";
      default = { };
    };

    perSystem = mkPerSystemOption (import ./clojureProject.nix);
  };
}
