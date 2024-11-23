(ns lojix.defun-test
  (:require
   [malli.experimental :refer [defn]]
   [malli.instrument :as mi]
   [malli.core :as m]
   [clojure.test :refer [deftest is testing]]))

(defn times :- :int
  "x times y"
  [x :- :int, y :- :int]
  (* x y))

(mi/instrument!)

(deftest typed-functions-tests
  (testing "typed functions"
    (is (= (times 1 3) 3))))
