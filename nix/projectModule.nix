{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;

  perSystemModule = { ... }: {
    imports = [ ./perSystemProjectModule.nix ];

    # config.clojureProjects = {};
  };

in
{
  options = {
    perSystem = mkPerSystemOption perSystemModule;
  };
}
