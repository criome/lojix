{
  description = "A `flake-parts` module for Clojure development";

  inputs = {
    nixpkgs = { type = "indirect"; id = "nixpkgs"; };

    flakeWorld = {
      url = "github:sajban/flakeWorld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clj-nix = {
      type = "indirect";
      id = "clj-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = github:sajban/devshell/betterFlakeModule;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, flakeWorld, ... }:
    flakeWorld.lib.mkFlake { inherit inputs; }
      (import ./nix/flakePart.nix);
}
