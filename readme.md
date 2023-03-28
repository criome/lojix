# Lojix

A meta-programming data-interface, bootstrapped with [Nix][1], and the
basis for LojixOS, an upcoming fork/improvement of [NixOS][3].

## Motivation

The evident need for an "Ideal" framework, from the point of view of
the "consumer" - programmers and/or high-abstraction-users - or more
concisly, the logical-UI users.

## History

### Versions

#### Alpha Concepts

#### Phase Three

The concept is to create a universal data-oriented API around a Nix
abstraction. This API can then be used by an endless number of
projects, such as Sajban/Mentci - the planned Criome language and
user-interface.

#### Phase Two

The concept is to combine the greatest programming UI in current
existence, namely Clojure (to be upgraded to Sajban/Mentci), with the
most advanced software/OS-building project, namely Nix(OS), to produce
a replicatable and easily auditable full-stack programming framework,
which is currently given the name _Lojix_.

#### Phase One

The concept of "lisping" nix owes inspiration from [Guix][4]. The
homoiconic design of [Clojure][5] qualifies it as the most advanced
and beautifully designed programming interface today. The combination
of those technologies would deeply revolutionize software
production. Much Gratitude goes to all the great minds behind those
projects.

#### Phase Zero

Most of the original draft is a direct adaptation of
[haskell-flake][6]. Much gratitude also goes to the authors of
[flake-parts][2], which lojix depends on.

[1]: https://github.com/NixOS/nix
[2]: https://github.com/hercules-ci/flake-parts
[3]: https://nixos.org/
[4]: https://guix.gnu.org/
[5]: https://clojure.org/
[6]: https://github.com/srid/haskell-flake
