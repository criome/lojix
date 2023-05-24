{ lib, config, pkgs, ... }:
let
  testClojureProject = { };

in
{
  packages = {
    default = pkgs.hello;
  };
}
