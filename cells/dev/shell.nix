{ inputs, cell }:
let
  l = nixpkgs.lib // builtins;
  inherit (inputs) nixpkgs std;
  stdlib = std.lib;
  inherit (std.lib.dev) mkNixago;

in
l.mapAttrs (_: stdlib.dev.mkShell) {
  default = { ... }: {
    name = "Standard";
    nixago = [
      ((mkNixago stdlib.cfg.conform) { data = { inherit (inputs) cells; }; })
      ((mkNixago stdlib.cfg.treefmt) cell.configs.treefmt)
      ((mkNixago stdlib.cfg.editorconfig) cell.configs.editorconfig)
    ];
    commands =
      [
        {
          package = nixpkgs.reuse;
          category = "legal";
        }
        {
          package = nixpkgs.delve;
          category = "cli-dev";
          name = "dlv";
        }
      ] ;
  };

}
