(ns lojix.nix
  (:require
   [malli.core :as m])
  (:gen-class))

(def Systems
  [:enum
   "aarch64-darwin"
   "aarch64-linux"
   "x86_64-darwin"
   "x86_64-linux"])

(def Derivation
  [:map {:closed true}
   [:name :string]
   [:system Systems]
   [:builder :string]
   [:args {:optional true} [:vector :string]]
   [:outputs {:optional true :default ["out"]} [:vector :string]]])

