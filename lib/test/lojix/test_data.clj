(ns lojix.test-data)

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
