{ mkDerivation, base, bytestring, containers, HTTP, lambdabot-core
, mtl, network, network-uri, oeis, process, regex-tdfa, split
, stdenv, tagsoup, utf8-string
}:
mkDerivation {
  pname = "lambdabot-reference-plugins";
  version = "5.0.3";
  src = ./.;
  buildDepends = [
    base bytestring containers HTTP lambdabot-core mtl network
    network-uri oeis process regex-tdfa split tagsoup utf8-string
  ];
  homepage = "http://haskell.org/haskellwiki/Lambdabot";
  description = "Lambdabot reference plugins";
  license = "GPL";
}
