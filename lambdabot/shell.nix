{ nixpkgs ? import <nixpkgs> {}, compiler ? "ghc7101" }:

let

  callPackage = import ../haskell-packages.nix {
    packages = nixpkgs.pkgs.haskell.packages.${compiler};
  };

  drv = callPackage ./lambdabot.nix { };

in

  if nixpkgs.lib.inNixShell then drv.env else drv
