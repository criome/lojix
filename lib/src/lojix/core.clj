  (:require
   [malli.core :as m]
   [lojix.nix :as nix]))

(def Request
  [:enum Verification Transformation nix.Derivation])
