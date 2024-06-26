(ns lojix.main
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
   [:system Systems]])

(def test-derivation {:name "test-derivation"
                      :system "x86_64-linux"})

(defn -main
  [& args]
  (println (str
            "Validating test-derivation: "
            (m/validate Derivation test-derivation))))
