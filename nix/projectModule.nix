{ lib, flake-parts-lib, ... }:
let inherit (flake-parts-lib)
  mkPerSystemOption;

in
{
  options = {
    perSystem = mkPerSystemOption (import ./perSystemProjectModule.nix);
  };
}
