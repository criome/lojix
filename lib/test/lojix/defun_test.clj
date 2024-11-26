(ns lojix.defun-test
  (:require
   [malli.experimental :refer [defn]]
   [malli.instrument :as mi]
   [malli.core :as m]
   [clojure.test :refer [deftest is testing]]))

(defmulti times)

(defn times-int :- :int
  "x times y"
  [x :- :int, y :- :int]
  (* x y))

(deftest uninstrumented-typed-functions-tests
  (testing "uninstrumented typed functions"
    (is (= (times 1 "oops") 3))))

(mi/instrument!)

(deftest typed-functions-tests
  (testing "typed functions"
    (is (= (times 1 3) 3))
    (is (= (times 1 "oops") 3))))
