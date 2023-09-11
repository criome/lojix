{ inputs, cell }:
let
  inherit (inputs) nixpkgs lib;
  inherit (nixpkgs) stringsWithDeps;
  l = lib // builtins;
in
{
  treefmt = {
    data = {
      global.excludes = [
        "cells/presets/templates/**"
      ];
      formatter = {
        nix = {
          command = "alejandra";
          includes = [ "*.nix" ];
        };
        prettier = {
          command = "prettier";
          options = [ "--plugin" "prettier-plugin-toml" "--write" ];
          includes = [
            "*.css"
            "*.html"
            "*.js"
            "*.json"
            "*.jsx"
            "*.md"
            "*.mdx"
            "*.scss"
            "*.ts"
            "*.yaml"
            "*.toml"
          ];
        };
        shell = {
          command = "shfmt";
          options = [ "-i" "2" "-s" "-w" ];
          includes = [ "*.sh" ];
        };

        go = {
          command = "gofmt";
          options = [ "-w" ];
          includes = [ "*.go" ];
        };
        prettier = {
          excludes = [ "**.min.js" ];
        };
      };
    };
    packages = [
      nixpkgs.alejandra
      nixpkgs.nodePackages.prettier
      nixpkgs.nodePackages.prettier-plugin-toml
      nixpkgs.shfmt
      nixpkgs.go
    ];
    devshell.startup.prettier-plugin-toml = stringsWithDeps.noDepEntry ''
      export NODE_PATH=${nixpkgs.nodePackages.prettier-plugin-toml}/lib/node_modules:''${NODE_PATH-}
    '';
  };

  editorconfig = {
    hook.mode = "copy"; # already useful before entering the devshell
    data = {
      root = true;

      "*" = {
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
        charset = "utf-8";
        indent_style = "space";
        indent_size = 2;
      };

      "*.{diff,patch}" = {
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        indent_size = "unset";
      };

      "*.md" = {
        max_line_length = "off";
        trim_trailing_whitespace = false;
      };
      "{LICENSES/**,LICENSE}" = {
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        charset = "unset";
        indent_style = "unset";
        indent_size = "unset";
      };

      "*.xcf" = {
        charset = "unset";
        end_of_line = "unset";
        insert_final_newline = "unset";
        trim_trailing_whitespace = "unset";
        indent_style = "unset";
        indent_size = "unset";
      };
      "{*.go,go.mod}" = {
        indent_style = "tab";
        indent_size = 4;
      };
    };
  };
}
