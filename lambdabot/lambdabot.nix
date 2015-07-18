{ mkDerivation, base, lambdabot-core, lambdabot-haskell-plugins
, mtl, slack-api, stdenv
}:
mkDerivation {
  pname = "lambdabot";
  version = "5.0.3";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    base lambdabot-core lambdabot-haskell-plugins mtl slack-api
  ];
  homepage = "http://haskell.org/haskellwiki/Lambdabot";
  description = "Lambdabot is a development tool and advanced IRC bot";
  license = "GPL";
}
