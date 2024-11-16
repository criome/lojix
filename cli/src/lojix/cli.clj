(ns lojix.clj
  (:require
   [piotr-yuxuan.malli-cli :as malli-cli]
   [piotr-yuxuan.malli-cli.utils :refer [deep-merge]]))

(def Config
  [:map {:closed true, :decode/args-transformer malli-cli/args-transformer}
   [:show-config? {:optional true}
    [boolean? {:description "Print actual configuration value and exit."
               :arg-number 0}]]
   [:help {:optional true}
    [boolean? {:description "Display usage summary and exit."
               :short-option "-h"
               :arg-number 0}]]
   [:log-level
    [:enum
     {:description "Non-idempotent -v increases log level, --log-level sets it."
      ;; Express how to decode a string into an enum value.
      :decode/string keyword
      :short-option "-v"
      :short-option/arg-number 0
      :short-option/update-fn malli-cli/non-idempotent-option
      :default :error
      ;; Used in summary to pretty-print the default value to a string.
      :default->str name}
     :off :fatal :error :warn :info :debug :trace :all]]])
