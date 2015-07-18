{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7101" }:

let

  callPackage = import ../haskell-packages.nix {
    packages = nixpkgs.pkgs.haskell.packages.${compiler};
  };

in

  callPackage ./lambdabot.nix { }
