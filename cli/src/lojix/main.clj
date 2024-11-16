(ns lojix.main
  (:require
   [malli.core :as m]
   [piotr-yuxuan.malli-cli :as malli-cli]))

(defn load-config
  [args]
  (m/decode Config args malli-cli/cli-transformer))

(defn -main
  [& args]
  (let [config (load-config args)]
    (cond (not (m/validate Config config))
      (do (log/error "Invalid configuration value"
                     (m/explain Config config))
        (Thread/sleep 60000) ; Leave some time to retrieve the logs.
        (System/exit 1))

      (:show-config? config)
      (do (clojure.pprint/pprint config)
        (System/exit 0))

      (:help config)
      (do (println (simple-summary Config))
        (System/exit 0))

      :else
      (app/start config))))
