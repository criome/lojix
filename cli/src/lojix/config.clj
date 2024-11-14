(ns lojix.config
  (:require
   [malli.core :as m]
   [piotr-yuxuan.malli-cli :as malli-cli]
   [piotr-yuxuan.malli-cli.utils :refer [deep-merge]]
   [org.passen.malapropism.core :as malapropism]))

(def config-schema
  [:map
   [:env-key :keyword]
   [:scm-rev :string]
   [:port :int]])

(defn load-config
  [args]
  (deep-merge
   ;; Value retrieved from any configuration system you want
   (:value (configure {:key service-name
                       :env (env)
                       :version (version)}))
   ;; Command-line arguments, env-vars, and default values.
   (m/decode Config args malli-cli/cli-transformer)))
