(ns lojix-test.basic
  (:require
   [lojix.nix :as nix])
  (:gen-class))

(def hello-world-derivation
  {:name "hello-world-derivation"
   :system "x86_64-linux"
   :builder "/bin/sh"
   :args ["-c" "echo hello world > $out"]})

(defn -main
  [& args]
  (println (str
            "Validating hello-world-derivation: "
            (m/validate Derivation hello-world-derivation))))
