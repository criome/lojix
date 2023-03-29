# Straight fork of `nixpkgs/pkgs/development/haskell-modules`
# More configuration can be copied over later
{ pkgs
, lib
, cljNixOverlay
, overlays
}:
let
  inherit (lib) extends makeExtensible composeManyExtensions;

  cljNixOverlayDependencies = {
    inherit (pkgs) stdenv fetchurl fetchgit fetchFromGitHub nix-prefetch-git
      clojure leiningen jdk jdk17_headless graalvmCEPackages
      runtimeShell unzip gnugrep jq
      runCommand writeShellScriptBin writeText linkFarm
      rlwrap makeWrapper writeShellApplication
      ;
  };

  extensions = composeManyExtensions [
    cljNixOverlay
    overlays
  ];

  extensible-self = makeExtensible (extends extensions cljNixOverlayDependencies);

in
extensible-self
