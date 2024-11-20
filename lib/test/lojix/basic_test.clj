(ns lojix.basic-test
  (:require
   [malli.core :as m]
   [lojix.nix :as nix]
   [clojure.test :refer [are deftest is testing]]))

(def hello-world-derivation
  {:name "hello-world-derivation"
   :system "x86_64-linux"
   :builder "/bin/sh"
   :args ["-c" "echo hello world > $out"]})

(def bad-derivation
  {:name "hello-world-derivation"
   :system ["x86_64-linux" "aarch64-linux"]
   :builder "/bin/sh"
   :args ["-c" "echo bad derivation > $out"]})

(deftest derivation-typecheck
  (testing "hello-world"
    (is (m/validate nix/Derivation hello-world-derivation))))

(deftest failing-tests
  (testing "Tests that should fail"
    (is (not (m/validate nix/Derivation bad-derivation)))))


