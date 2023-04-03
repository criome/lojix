{ lib, config, pkgs, ... }:
let
  testClojureProject = { };

in
{
  clojureProjects.default = { };

  packages = {
    cljNixPackage = pkgs.clojurePackages.clj-builder;
  };
}
