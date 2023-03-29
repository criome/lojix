{ lib, config, ... }:
let
  testClojureProject = { };

in
{
  checks = {
    cljNixPackage = config.clojure.packages.clj-builder;
  };
}
