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

      mkClojurePackages = self: { };

      clojurePackages = makeScope newScope mkClojurePackages;

    in
    { clojurePackages = dontRecurseIntoAttrs clojurePackages; };



  clojureSubmodule = types.submodule {
    options = {
      overlays = mkOption {
        description = "Clojure packages";
        type = import ./clojureOverlayType.nix lib;
        example = "prev: final: { }";
        default = clojurePackagesBaseOverlay;
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
