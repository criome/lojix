lib:
types.mkOptionType {
  name = "nixpkgsOverlay";
  description = "A nixpkgs overlay function";
  descriptionClass = "noun";
  check = lib.isFunction;
  merge = _loc: defs:
    let
      logWarning =
        # TODO: do not warn when lib.mkOrder/mkBefore/mkAfter are used unambiguously
        if builtins.length defs > 1
        then builtins.trace "WARNING[nixpkgs.flakeModule]: Multiple overlays are applied in arbitrary order." null
        else null;
      overlays =
        map (x: x.value)
          # TODO: lib.warnIf to replace the seq + if
          (builtins.seq
            logWarning
            defs);
    in
    lib.composeManyExtensions overlays;
};
