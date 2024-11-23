(ns lojix.basic-test
  (:require
   [lojix.test-data :as data]
   [malli.core :as m]
   [lojix.nix :as nix]
   [clojure.test :refer [deftest is testing]]))

(deftest derivation-typecheck
  (testing "hello-world"
    (is (m/validate nix/Derivation data/hello-world-derivation))))

(deftest failing-tests
  (testing "Tests that should fail"
    (is (not (m/validate nix/Derivation data/bad-derivation)))))


