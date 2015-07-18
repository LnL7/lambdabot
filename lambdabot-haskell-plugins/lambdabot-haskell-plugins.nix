{ mkDerivation, array, arrows, base, bytestring, containers
, data-memocombinators, directory, filepath, haskell-src-exts
, hoogle, HTTP, IOSpec, lambdabot-core, lambdabot-reference-plugins
, lambdabot-trusted, lifted-base, logict, MonadRandom, mtl, mueval
, network, numbers, oeis, parsec, pretty, process, QuickCheck
, regex-tdfa, show, split, stdenv, syb, transformers, utf8-string
, vector-space
}:
mkDerivation {
  pname = "lambdabot-haskell-plugins";
  version = "5.0.3";
  src = ./.;
  buildDepends = [
    array arrows base bytestring containers data-memocombinators
    directory filepath haskell-src-exts hoogle HTTP IOSpec
    lambdabot-core lambdabot-reference-plugins lambdabot-trusted
    lifted-base logict MonadRandom mtl mueval network numbers oeis
    parsec pretty process QuickCheck regex-tdfa show split syb
    transformers utf8-string vector-space
  ];
  homepage = "http://haskell.org/haskellwiki/Lambdabot";
  description = "Lambdabot Haskell plugins";
  license = "GPL";
}
