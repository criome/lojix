(ns lojix.basic-test
  (:require
   [malli.core :as malli]
   [lojix.nix :as nix]
   [clojure.test :refer [are deftest is testing]]))

(def hello-world-derivation
  {:name "hello-world-derivation"
   :system "x86_64-linux"
   :builder "/bin/sh"
   :args ["-c" "echo hello world > $out"]})

(deftest derivation-typecheck
  (testing "hello-world"
    (is (malli/validate nix/Derivation hello-world-derivation))))
