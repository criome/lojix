{ lib, config, pkgs, ... }:
let
  testClojureProject = { };

in
{
  clojureProjects.default = {
    cljNixPackage = pkgs.clojurePackages.clj-builder;
  };
}
