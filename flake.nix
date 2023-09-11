{
  description = "A `flake-parts` module for Clojure development";

  inputs = {
    flakeWorld = { type = "indirect"; id = "flakeWorld"; };
    nixpkgs = { type = "indirect"; id = "nixpkgs"; };
    systems = { type = "indirect"; id = "systems"; };

    devshell = {
      type = "indirect";
      id = "devshell";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
      };
    };
    
    clj-nix = {
      type = "indirect";
      id = "clj-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flakeWorld, ... }:
    flakeWorld.make.simple { inherit inputs; };
}
