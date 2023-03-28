{
  description = "A `flake-parts` module for Clojure development";

  inputs = {
    nixpkgs = { type = "indirect"; id = "nixpkgs"; };
    lib = { type = "indirect"; id = "lib"; };

    clj-nix = {
      type = "indirect";
      id = "clj-nix";
      nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      type = "indirect";
      id = "flake-parts";
      nixpkgs-lib.follows = "lib";
    };

  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      import ./nix/flakePart.nix;
}
