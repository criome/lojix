(ns lojix.main
  (:require
   [clojure.string :as string]
   [malli.core :as m])
  (:gen-class))

(def non-empty-string
  (m/schema [:string {:min 1}]))

(defn -main
  [& args]
  (println (str "Validating something: " (m/schema? non-empty-string))))
