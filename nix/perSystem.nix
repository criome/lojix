{ lib, config, pkgs, clojix, ... }:
let
  inherit (pkgs) stdenv;

  testProject = stdenv.mkDerivation {
    name = "clojixTestProject";
    src = clojix.sources.testProject;
  };

in
{
  packages = {
    default = testProject;
  };
}
