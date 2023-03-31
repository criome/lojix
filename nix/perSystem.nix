{ lib, config, pkgs, ... }:
let
  testClojureProject = { };

in
{
  packages = {
    cljNixPackage = pkgs.clojurePackages.clj-builder;
  };
}
