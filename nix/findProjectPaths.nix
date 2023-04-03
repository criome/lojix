{ root, lib, name }:
let
  inherit (builtins) pathExists;

  findUnfilteredPaths = key: value:
    let
      mkUnfilteredPackageValue = name: path:
        lib.nameValuePair name { projectSrc = path; };
    in
    if value == "regular" && key == "project.clj"
    then mkUnfilteredPackageValue name root
    else
      if value == "directory" && pathExists (root + "/${key}/project.clj")
      then mkUnfilteredPackageValue key (root + "/${key}")
      else mkUnfilteredPackageValue key null;

  leningenPathsInDir' = path:
    lib.filterAttrs (k: v: v != null) (lib.mapAttrs'
      findUnfilteredPaths
      (builtins.readDir path));

  errorNoDefault = msg:
    builtins.throw '' 
      clojix: A default value for `packages` cannot be auto-detected:
        ${msg}
      You must manually specify either the `root` or `packages` option.
    '';
  leningenPaths =
    let
      leningenPaths = leningenPathsInDir' root;
    in
    if root == null
    then
      errorNoDefault ''
        No project root specified.
      ''
    else
      if leningenPaths == { }
      then
        errorNoDefault ''
          No project.edn file found in project root or its sub-directories.
        ''
      else leningenPaths;

in
leningenPaths

