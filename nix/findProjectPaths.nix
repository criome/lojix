{ lib, ... }:

self:
let
  leningenPathsInDir' = path:
    lib.filterAttrs (k: v: v != null) (lib.mapAttrs'
      (k: v:
        if v == "regular" && k == "project.edn"
        then path
        else
          if v == "directory" && builtins.pathExists (path + "/${k}/project.edn")
          then lib.nameValuePair k (path + "/${k}")
          else lib.nameValuePair k null
      )
      (builtins.readDir path));
  errorNoDefault = msg:
    builtins.throw '' 
      clojix: A default value for `packages` cannot be auto-detected:

        ${msg}
      You must manually specify the `packages` option.
    '';
  leningenPaths =
    let
      leningenPaths = leningenPathsInDir' self;
    in
    if leningenPaths == { }
    then
      errorNoDefault ''
        No project.edn file found in project root or its sub-directories.
      ''
    else leningenPaths;
in
leningenPaths

